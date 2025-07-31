//
//  FlightService.swift
//  AvApp
//
//  Created by Hasan Zaidi on 7/31/25.
//


import Foundation

class FlightService {
    static let shared = FlightService()

    private let apiKey = "31bdfc9f18msh533e951dc1c6231p15dca6jsn722cdc0000a9"
    private let baseURL = "https://aerodatabox.p.rapidapi.com/flights/airports/iata/"

    func fetchFlights(for airportCode: String) async throws -> FlightResponse {
        let query = "?offsetMinutes=-120&durationMinutes=720&withLeg=true&direction=Both&withCancelled=true&withCodeshared=true&withCargo=true&withPrivate=true&withLocation=false"
        guard let url = URL(string: "\(baseURL)\(airportCode)\(query)") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("aerodatabox.p.rapidapi.com", forHTTPHeaderField: "x-rapidapi-host")
        request.addValue(apiKey, forHTTPHeaderField: "x-rapidapi-key")

        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(FlightResponse.self, from: data)
    }
}
