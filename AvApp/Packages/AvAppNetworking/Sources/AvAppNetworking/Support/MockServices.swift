import Foundation

public struct MockFlightService: FlightFetching, @unchecked Sendable {
    public var response: FlightResponse
    public var error: Error?

    public init(
        response: FlightResponse = FlightResponse(departures: [.mock], arrivals: [.mock]),
        error: Error? = nil
    ) {
        self.response = response
        self.error = error
    }

    public func fetchFlights(for airportCode: String) async throws -> FlightResponse {
        if let error { throw error }
        return response
    }
}

public struct MockAircraftService: AircraftFetching, @unchecked Sendable {
    public var detail: AircraftDetail
    public var error: Error?

    public init(detail: AircraftDetail = .mock, error: Error? = nil) {
        self.detail = detail
        self.error = error
    }

    public func fetchAircraftDetail(registration: String) async throws -> AircraftDetail {
        if let error { throw error }
        return detail
    }
}

public struct MockTrackService: TrackFetching, @unchecked Sendable {
    public var track: AircraftTrack
    public var error: Error?

    public init(track: AircraftTrack = .mock, error: Error? = nil) {
        self.track = track
        self.error = error
    }

    public func fetchTrack(icao24: String, time: Int) async throws -> AircraftTrack {
        if let error { throw error }
        return track
    }
}
