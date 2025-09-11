//
//  NetworkClient.swift
//  AvAppNetworking
//
//  Created by Hasan Zaidi on 9/10/25.
//

import Foundation

public protocol NetworkClient {
    func request<T: Decodable>(_ endpoint: URLRequest) async throws -> T
}

public final class URLSessionNetworkClient: NetworkClient {
    private let session: URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    public func request<T: Decodable>(_ endpoint: URLRequest) async throws -> T {
        let (data, response) = try await session.data(for: endpoint)
        
        if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
            throw NetworkError.serverError(httpResponse.statusCode)
        }
        
        return try JSONDecoder().decode(T.self, from: data)
    }
}
