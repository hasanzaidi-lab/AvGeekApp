//
//  AircraftService.swift
//  AvAppNetworking
//
//  Created by Hasan Zaidi on 9/10/25.
//

import Foundation

public final class AircraftService: AircraftFetching, Sendable {
    private let client: NetworkClient
    private let apiKey: String
    private let host: String
    private let baseURL = "https://aerodatabox.p.rapidapi.com/aircrafts/reg/"

    public init(
        client: NetworkClient = URLSessionNetworkClient(),
        apiKey: String,
        host: String = "aerodatabox.p.rapidapi.com"
    ) {
        self.client = client
        self.apiKey = apiKey
        self.host = host
    }

    public func fetchAircraftDetail(registration: String) async throws -> AircraftDetail {
        guard !apiKey.isEmpty else {
            throw NetworkError.missingAPIKey
        }

        let sanitized = registration.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        let urlString = baseURL + sanitized
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL(urlString)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(host, forHTTPHeaderField: "x-rapidapi-host")
        request.setValue(apiKey, forHTTPHeaderField: "x-rapidapi-key")

        return try await client.request(request)
    }
}
