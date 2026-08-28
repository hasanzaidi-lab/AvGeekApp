import Foundation
import SwiftUI
import AvAppNetworking

struct AppDependencies {
    var flightService: any FlightFetching
    var aircraftService: any AircraftFetching
    var trackService: any TrackFetching

    static var live: AppDependencies {
        let apiKey = APIConfiguration.rapidAPIKey
        let client = URLSessionNetworkClient()
        return AppDependencies(
            flightService: FlightService(client: client, apiKey: apiKey),
            aircraftService: AircraftService(client: client, apiKey: apiKey),
            trackService: TrackService(client: client)
        )
    }

    static var preview: AppDependencies {
        AppDependencies(
            flightService: MockFlightService(),
            aircraftService: MockAircraftService(),
            trackService: MockTrackService()
        )
    }
}

private struct AppDependenciesKey: EnvironmentKey {
    static let defaultValue = AppDependencies.live
}

extension EnvironmentValues {
    var appDependencies: AppDependencies {
        get { self[AppDependenciesKey.self] }
        set { self[AppDependenciesKey.self] = newValue }
    }
}
