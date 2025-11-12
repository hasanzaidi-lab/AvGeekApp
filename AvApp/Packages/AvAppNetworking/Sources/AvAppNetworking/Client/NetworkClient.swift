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
        do {
            let (data, response) = try await session.data(for: endpoint)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                throw NetworkError.serverError(statusCode: httpResponse.statusCode, data: data)
            }
            
            do {
                return try JSONDecoder().decode(T.self, from: data)
            } catch let decodingError as DecodingError {
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("🔍 Raw JSON:\n\(jsonString)")
                }
                throw NetworkError.decodingError(decodingError)
            }
        } catch let urlError as URLError {
            throw NetworkError.transportError(urlError)
        } catch {
            throw NetworkError.unexpectedError(error)
        }
    }
}
