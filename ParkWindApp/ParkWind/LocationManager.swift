import CoreLocation

enum LocationError: LocalizedError {
    case denied
    case unavailable

    var errorDescription: String? {
        switch self {
        case .denied: return "Location permission denied — allow it in Settings ▸ Privacy ▸ Location Services."
        case .unavailable: return "Couldn't get a GPS fix."
        }
    }
}

final class LocationManager: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private var continuation: CheckedContinuation<CLLocationCoordinate2D, Error>?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    func currentLocation() async throws -> CLLocationCoordinate2D {
        try await withCheckedThrowingContinuation { cont in
            continuation = cont
            switch manager.authorizationStatus {
            case .authorizedWhenInUse, .authorizedAlways:
                manager.requestLocation()
            case .denied, .restricted:
                finish(.failure(LocationError.denied))
            default:
                manager.requestWhenInUseAuthorization()
            }
        }
    }

    private func finish(_ result: Result<CLLocationCoordinate2D, Error>) {
        guard let cont = continuation else { return }
        continuation = nil
        cont.resume(with: result)
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        guard continuation != nil else { return }
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        case .denied, .restricted:
            finish(.failure(LocationError.denied))
        default:
            break // still .notDetermined — waiting for the user
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let loc = locations.first {
            finish(.success(loc.coordinate))
        } else {
            finish(.failure(LocationError.unavailable))
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        finish(.failure(error))
    }
}
