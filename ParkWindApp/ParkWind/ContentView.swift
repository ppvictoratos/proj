import SwiftUI

@main
struct ParkWindApp: App {
    var body: some SwiftUI.Scene {
        WindowGroup { ContentView() }
    }
}

struct ContentView: View {
    enum Phase {
        case locating
        case failed(String)
        case confirm
        case picking
        case loading(String)
        case map(ParkScene)
    }

    @State private var phase: Phase = .locating
    @State private var userLat = 0.0
    @State private var userLon = 0.0
    @State private var nearbyParks: [Park] = []
    @State private var searchText = ""
    @State private var searchResults: [Park]?
    @AppStorage("imperialUnits") private var imperial =
        Locale.current.measurementSystem == .us

    private let location = LocationManager()

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(red: 0.86, green: 0.94, blue: 0.86),
                                    Color(red: 0.95, green: 0.97, blue: 0.94)],
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            switch phase {
            case .locating:
                card {
                    Text("🌳💨").font(.system(size: 44))
                    Text("ParkWind").font(.largeTitle.bold())
                    ProgressView("Finding you…").padding(.top, 8)
                }
                .task { await locate() }

            case .failed(let message):
                card {
                    Text("🌳💨").font(.system(size: 44))
                    Text(message)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    Button("Try again") { phase = .locating }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                }

            case .confirm:
                card {
                    Text("📍").font(.system(size: 44))
                    Text("Is this your location?").font(.title2.bold())
                    if let first = nearbyParks.first {
                        Text(first.name).font(.title.bold())
                        Text("\(first.kind.capitalized) · \(formatDistance(first.distance)) away")
                            .foregroundStyle(.secondary)
                        Button("Yes!") { load(first) }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.large)
                            .padding(.top, 6)
                        Button("No — pick another") { phase = .picking }
                            .buttonStyle(.bordered)
                            .controlSize(.large)
                    }
                }

            case .picking:
                picker

            case .loading(let message):
                card { ProgressView(message) }

            case .map(let scene):
                ParkCanvasView(scene: scene, imperial: $imperial) {
                    searchText = ""
                    searchResults = nil
                    phase = .picking
                }
            }
        }
    }

    private func card<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        VStack(spacing: 12, content: content)
            .padding(30)
            .frame(maxWidth: 460)
            .background(.white, in: RoundedRectangle(cornerRadius: 24))
            .shadow(color: .black.opacity(0.12), radius: 20, y: 8)
            .padding()
    }

    private var picker: some View {
        VStack(spacing: 0) {
            Text("Pick a park").font(.title2.bold()).padding(.top, 20)
            TextField("Search parks near you…", text: $searchText)
                .textFieldStyle(.roundedBorder)
                .padding()
                .onChange(of: searchText) {
                    Task { await search() }
                }
            List(searchResults ?? nearbyParks) { park in
                Button {
                    load(park)
                } label: {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(park.name).font(.headline)
                            Text(park.kind.capitalized)
                                .font(.subheadline).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text(formatDistance(park.distance))
                            .font(.subheadline).foregroundStyle(.secondary)
                    }
                }
                .foregroundStyle(.primary)
            }
            .listStyle(.plain)
            Button("Back") { phase = .confirm }
                .buttonStyle(.bordered)
                .controlSize(.large)
                .padding()
        }
        .frame(maxWidth: 520, maxHeight: 640)
        .background(.white, in: RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.12), radius: 20, y: 8)
        .padding()
    }

    // MARK: Actions

    private func locate() async {
        do {
            let coord = try await location.currentLocation()
            userLat = coord.latitude
            userLon = coord.longitude
            nearbyParks = try await API.nearbyParks(lat: userLat, lon: userLon)
            guard !nearbyParks.isEmpty else {
                phase = .failed("No parks found nearby. Try again somewhere greener 🌵")
                return
            }
            phase = .confirm
        } catch {
            phase = .failed(error.localizedDescription)
        }
    }

    private func search() async {
        let text = searchText.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { searchResults = nil; return }
        try? await Task.sleep(for: .milliseconds(400))   // debounce
        guard text == searchText.trimmingCharacters(in: .whitespaces) else { return }
        searchResults = (try? await API.searchParks(text, lat: userLat, lon: userLon)) ?? []
    }

    private func load(_ park: Park) {
        phase = .loading("Loading \(park.name)…")
        Task {
            do {
                phase = .map(try await API.loadScene(for: park))
            } catch {
                phase = .confirm
            }
        }
    }

    private func formatDistance(_ meters: Double) -> String {
        if imperial {
            return meters < 160 ? "\(Int(meters * 3.28)) ft"
                                : String(format: "%.1f mi", meters / 1609.34)
        }
        return meters < 1000 ? "\(Int(meters)) m" : String(format: "%.1f km", meters / 1000)
    }
}
