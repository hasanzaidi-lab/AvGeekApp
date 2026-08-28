//
//  ServiceProtocols.swift
//  AvAppNetworking
//

import Foundation

public protocol FlightFetching: Sendable {
    func fetchFlights(for airportCode: String) async throws -> FlightResponse
}

public protocol AircraftFetching: Sendable {
    func fetchAircraftDetail(registration: String) async throws -> AircraftDetail
}

public protocol TrackFetching: Sendable {
    func fetchTrack(icao24: String, time: Int) async throws -> AircraftTrack
}

public extension TrackFetching {
    func fetchTrack(icao24: String) async throws -> AircraftTrack {
        try await fetchTrack(icao24: icao24, time: 0)
    }
}
