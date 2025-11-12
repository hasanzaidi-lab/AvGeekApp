// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

public final class FlightService {
    nonisolated(unsafe) public static let shared = FlightService()

    private let apiKey = "31bdfc9f18msh533e951dc1c6231p15dca6jsn722cdc0000a9"
    private let baseURL = "https://aerodatabox.p.rapidapi.com/flights/airports/iata/"

    public init() {}  // make init public if you ever want to create custom instances

    public func fetchFlights(for airportCode: String) async throws -> FlightResponse {
        let query = "?offsetMinutes=-120&durationMinutes=720&withLeg=true&direction=Both&withCancelled=true&withCodeshared=true&withCargo=true&withPrivate=true&withLocation=false"
        guard let url = URL(string: "\(baseURL)\(airportCode)\(query)") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("aerodatabox.p.rapidapi.com", forHTTPHeaderField: "X-RapidAPI-Host")
        request.addValue(apiKey, forHTTPHeaderField: "X-RapidAPI-Key")

        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(FlightResponse.self, from: data)
    }
}
