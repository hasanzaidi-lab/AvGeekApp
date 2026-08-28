//
//  TrackService.swift
//  AvAppNetworking
//
//  Created by Hasan Zaidi on 11/26/25.
//

import Foundation

public final class TrackService: TrackFetching, Sendable {
    private let client: NetworkClient
    private let baseURL = "https://opensky-network.org/api/tracks/all"

    public init(client: NetworkClient = URLSessionNetworkClient()) {
        self.client = client
    }

    public func fetchTrack(icao24: String, time: Int = 0) async throws -> AircraftTrack {
        guard var components = URLComponents(string: baseURL) else {
            throw NetworkError.invalidURL(baseURL)
        }

        components.queryItems = [
            URLQueryItem(name: "icao24", value: icao24.lowercased()),
            URLQueryItem(name: "time", value: String(time))
        ]

        guard let url = components.url else {
            throw NetworkError.invalidURL(baseURL + "?" + (components.percentEncodedQuery ?? ""))
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        return try await client.request(request)
    }
}
