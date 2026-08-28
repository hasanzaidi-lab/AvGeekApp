//
//  NetworkClient.swift
//  AvAppNetworking
//
//  Created by Hasan Zaidi on 9/10/25.
//

import Foundation

public protocol NetworkClient: Sendable {
    func request<T: Decodable>(_ endpoint: URLRequest) async throws -> T
}

public final class URLSessionNetworkClient: NetworkClient, Sendable {
    private let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }

    public func request<T: Decodable>(_ endpoint: URLRequest) async throws -> T {
        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await session.data(for: endpoint)
        } catch let urlError as URLError {
            throw NetworkError.transportError(urlError)
        } catch {
            throw NetworkError.unexpectedError(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.serverError(statusCode: httpResponse.statusCode, data: data)
        }

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch let decodingError as DecodingError {
            throw NetworkError.decodingError(decodingError)
        } catch {
            throw NetworkError.unexpectedError(error)
        }
    }
}
