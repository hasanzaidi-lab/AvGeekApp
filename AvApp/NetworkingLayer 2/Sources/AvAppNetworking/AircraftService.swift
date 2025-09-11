//
//  AircraftService.swift
//  AvAppNetworking
//
//  Created by Hasan Zaidi on 9/10/25.
//

import Foundation

public final class AircraftService {
    private let client: NetworkClient
    private let baseURL = "https://aerodatabox.p.rapidapi.com/aircrafts/reg/"
    private let headers: [String: String]
    
    nonisolated(unsafe) public static let shared = AircraftService(
        client: URLSessionNetworkClient(), apiKey: "31bdfc9f18msh533e951dc1c6231p15dca6jsn722cdc0000a9"
    )
   
    public init(client: NetworkClient, apiKey: String, host: String = "aerodatabox.p.rapidapi.com") {
        self.client = client
        self.headers = [
            "x-rapidapi-host": host,
            "x-rapidapi-key": apiKey
        ]
    }
    
    public func fetchAircraftDetail(registration: String) async throws -> AircraftDetail {
        guard let url = URL(string: baseURL + registration) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        headers.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }
        
        return try await client.request(request)
    }
}
