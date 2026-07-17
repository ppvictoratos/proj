import Foundation

enum APIError: LocalizedError {
    case unreachable(String)
    case badData(String)

    var errorDescription: String? {
        switch self {
        case .unreachable(let s): return "Couldn't reach \(s) — check the tether and retry."
        case .badData(let s): return s
        }
    }
}

enum API {
    private static let overpassMirrors = [
        "https://overpass-api.de/api/interpreter",
        "https://overpass.kumi.systems/api/interpreter",
    ]
    private static let parkKinds = "park|garden|nature_reserve|recreation_ground|dog_park|golf_course|common"

    // MARK: Overpass

    private static func overpass(_ query: String) async throws -> [[String: Any]] {
        var lastError: Error = APIError.unreachable("OpenStreetMap")
        let allowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-._~"))
        let body = "data=" + (query.addingPercentEncoding(withAllowedCharacters: allowed) ?? query)
        for mirror in overpassMirrors {
            do {
                var req = URLRequest(url: URL(string: mirror)!)
                req.httpMethod = "POST"
                req.httpBody = body.data(using: .utf8)
                req.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                let (data, resp) = try await URLSession.shared.data(for: req)
                guard (resp as? HTTPURLResponse)?.statusCode == 200 else {
                    throw APIError.unreachable("OpenStreetMap")
                }
                guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let elements = json["elements"] as? [[String: Any]] else {
                    throw APIError.badData("Unexpected OpenStreetMap response")
                }
                return elements
            } catch {
                lastError = error
            }
        }
        throw lastError
    }

    static func nearbyParks(lat: Double, lon: Double) async throws -> [Park] {
        for radius in [3000, 10000, 30000] {
            let q = """
            [out:json][timeout:25];
            (way["leisure"~"^(\(parkKinds))$"]["name"](around:\(radius),\(lat),\(lon));
             relation["leisure"~"^(\(parkKinds))$"]["name"](around:\(radius),\(lat),\(lon)););
            out tags center 60;
            """
            let parks = dedupe(try await overpass(q), lat: lat, lon: lon)
            if !parks.isEmpty { return parks }
        }
        return []
    }

    static func searchParks(_ text: String, lat: Double, lon: Double) async throws -> [Park] {
        let safe = text.filter { $0.isLetter || $0.isNumber || $0 == " " }
        guard !safe.isEmpty else { return [] }
        let q = """
        [out:json][timeout:25];
        (way["leisure"~"^(\(parkKinds))$"]["name"~"\(safe)",i](around:40000,\(lat),\(lon));
         relation["leisure"~"^(\(parkKinds))$"]["name"~"\(safe)",i](around:40000,\(lat),\(lon)););
        out tags center 40;
        """
        return dedupe(try await overpass(q), lat: lat, lon: lon)
    }

    private static func dedupe(_ elements: [[String: Any]], lat: Double, lon: Double) -> [Park] {
        var seen = Set<String>()
        var out: [Park] = []
        for el in elements {
            let center = el["center"] as? [String: Any] ?? el
            guard let id = el["id"] as? Int,
                  let type = el["type"] as? String,
                  let cLat = center["lat"] as? Double,
                  let cLon = center["lon"] as? Double,
                  let tags = el["tags"] as? [String: Any],
                  let name = tags["name"] as? String,
                  seen.insert(name.lowercased()).inserted else { continue }
            let kind = (tags["leisure"] as? String ?? "park").replacingOccurrences(of: "_", with: " ")
            out.append(Park(id: id, osmType: type, name: name, kind: kind, lat: cLat, lon: cLon,
                            distance: Geo.haversine(lat, lon, cLat, cLon)))
        }
        return out.sorted { $0.distance < $1.distance }
    }

    // MARK: Park geometry + features

    static func loadScene(for park: Park) async throws -> ParkScene {
        let q = "[out:json][timeout:25];\(park.osmType)(\(park.id));out geom;"
        guard let el = try await overpass(q).first else {
            throw APIError.badData("Park outline not found")
        }

        var latLonRings: [[(Double, Double)]] = []
        if park.osmType == "way", let geom = el["geometry"] as? [[String: Any]] {
            latLonRings = [geom.compactMap { g in
                guard let la = g["lat"] as? Double, let lo = g["lon"] as? Double else { return nil }
                return (la, lo)
            }]
        } else if let members = el["members"] as? [[String: Any]] {
            let outerSegs: [[(Double, Double)]] = members.compactMap { m in
                guard m["type"] as? String == "way",
                      let role = m["role"] as? String, role == "outer" || role.isEmpty,
                      let geom = m["geometry"] as? [[String: Any]] else { return nil }
                return geom.compactMap { g in
                    guard let la = g["lat"] as? Double, let lo = g["lon"] as? Double else { return nil }
                    return (la, lo)
                }
            }
            // stitch below, after projecting
            latLonRings = outerSegs
        }
        guard !latLonRings.isEmpty else { throw APIError.badData("Unsupported park outline") }

        let allLats = latLonRings.flatMap { $0.map(\.0) }
        let allLons = latLonRings.flatMap { $0.map(\.1) }
        guard let south = allLats.min(), let north = allLats.max(),
              let west = allLons.min(), let east = allLons.max() else {
            throw APIError.badData("Empty park outline")
        }
        let cLat = (south + north) / 2
        let cLon = (west + east) / 2
        let project = Geo.projector(centerLat: cLat, centerLon: cLon)

        var rings = latLonRings.map { $0.map { project($0.0, $0.1) } }
        if park.osmType == "relation" {
            rings = Geo.stitchRings(rings)
            guard !rings.isEmpty else { throw APIError.badData("Unsupported park outline") }
        }

        let features = (try? await loadFeatures(
            south: south, west: west, north: north, east: east,
            project: project)) ?? ParkFeatures()

        let grid = Geo.sampleGrid(in: rings[0])
        let kx = 111_320 * cos(cLat * .pi / 180), ky = 110_574.0
        let coords = grid.map { (lat: cLat + $0.y / ky, lon: cLon + $0.x / kx) }
        let weather = try await fetchWeather(coords)

        var spots: [Spot] = []
        for (i, p) in grid.enumerated() {
            var spot = Spot(id: i, x: p.x, y: p.y, lat: coords[i].lat, lon: coords[i].lon,
                            weather: weather[i])
            let micro = Microclimate.evaluate(at: p, weather: weather[i], features: features)
            spot.feels = micro.feels
            spot.descriptor = micro.descriptor
            spots.append(spot)
        }

        return ParkScene(park: park, rings: rings, features: features, spots: spots,
                         centerLat: cLat, centerLon: cLon)
    }

    private static func loadFeatures(south: Double, west: Double, north: Double, east: Double,
                                     project: (Double, Double) -> SIMD2<Double>) async throws -> ParkFeatures {
        let b = "(\(south),\(west),\(north),\(east))"
        let q = """
        [out:json][timeout:30];
        (node["natural"="tree"]\(b);
         way["natural"~"^(water|wood|scrub)$"]\(b);
         way["landuse"~"^(grass|forest|meadow|flowerbed)$"]\(b);
         way["leisure"~"^(pitch|playground|garden|swimming_pool)$"]\(b);
         way["highway"~"^(path|footway|cycleway|track|pedestrian|steps|service)$"]\(b);
         way["building"]\(b););
        out geom 1500;
        """
        var f = ParkFeatures()
        for el in try await overpass(q) {
            let tags = el["tags"] as? [String: Any] ?? [:]
            if el["type"] as? String == "node", tags["natural"] as? String == "tree",
               let la = el["lat"] as? Double, let lo = el["lon"] as? Double {
                f.trees.append(project(la, lo))
                continue
            }
            guard el["type"] as? String == "way",
                  let geom = el["geometry"] as? [[String: Any]] else { continue }
            let coords: [SIMD2<Double>] = geom.compactMap { g in
                guard let la = g["lat"] as? Double, let lo = g["lon"] as? Double else { return nil }
                return project(la, lo)
            }
            if tags["natural"] as? String == "water" || tags["leisure"] as? String == "swimming_pool" {
                f.water.append(coords)
            } else if ["wood", "scrub"].contains(tags["natural"] as? String)
                        || tags["landuse"] as? String == "forest" {
                f.woods.append(coords)
            } else if tags["landuse"] != nil || tags["leisure"] as? String == "garden" {
                f.greens.append(coords)
            } else if ["pitch", "playground"].contains(tags["leisure"] as? String) {
                f.pitches.append(coords)
            } else if tags["highway"] != nil {
                f.paths.append(coords)
            } else if tags["building"] != nil {
                f.buildings.append(coords)
            }
        }
        if f.trees.count > 500 {
            let step = f.trees.count / 500 + 1
            f.trees = f.trees.enumerated().filter { $0.offset % step == 0 }.map(\.element)
        }
        return f
    }

    // MARK: Open-Meteo

    private struct OMResponse: Decodable {
        struct Current: Decodable {
            let temperature_2m: Double
            let apparent_temperature: Double
            let is_day: Int
            let wind_speed_10m: Double
            let wind_direction_10m: Double
        }
        struct Hourly: Decodable {
            let wind_speed_80m: [Double]
            let wind_direction_80m: [Double]
            let wind_speed_120m: [Double]
            let wind_direction_120m: [Double]
            let temperature_80m: [Double]
            let temperature_120m: [Double]
        }
        let current: Current
        let hourly: Hourly
    }

    static func fetchWeather(_ coords: [(lat: Double, lon: Double)]) async throws -> [SpotWeather] {
        let lats = coords.map { String(format: "%.4f", $0.lat) }.joined(separator: ",")
        let lons = coords.map { String(format: "%.4f", $0.lon) }.joined(separator: ",")
        let url = URL(string: "https://api.open-meteo.com/v1/forecast?latitude=\(lats)&longitude=\(lons)"
            + "&current=temperature_2m,apparent_temperature,is_day,wind_speed_10m,wind_direction_10m"
            + "&hourly=wind_speed_80m,wind_direction_80m,wind_speed_120m,wind_direction_120m,"
            + "temperature_80m,temperature_120m"
            + "&forecast_hours=2&wind_speed_unit=kmh&timezone=auto")!
        let (data, resp) = try await URLSession.shared.data(from: url)
        guard (resp as? HTTPURLResponse)?.statusCode == 200 else {
            throw APIError.unreachable("Open-Meteo")
        }
        let decoder = JSONDecoder()
        let locations: [OMResponse]
        if let many = try? decoder.decode([OMResponse].self, from: data) {
            locations = many
        } else {
            locations = [try decoder.decode(OMResponse.self, from: data)]
        }
        guard locations.count == coords.count else {
            throw APIError.badData("Weather response mismatch")
        }
        return locations.map { loc in
            SpotWeather(
                temperature: loc.current.temperature_2m,
                apparent: loc.current.apparent_temperature,
                isDay: loc.current.is_day == 1,
                levels: [
                    WindLevel(height: 10, speed: loc.current.wind_speed_10m,
                              direction: loc.current.wind_direction_10m,
                              temperature: loc.current.temperature_2m),
                    WindLevel(height: 80, speed: loc.hourly.wind_speed_80m[0],
                              direction: loc.hourly.wind_direction_80m[0],
                              temperature: loc.hourly.temperature_80m[0]),
                    WindLevel(height: 120, speed: loc.hourly.wind_speed_120m[0],
                              direction: loc.hourly.wind_direction_120m[0],
                              temperature: loc.hourly.temperature_120m[0]),
                ])
        }
    }
}
