//
//  MockNetworkClient.swift
//  AvAppNetworking
//

import Foundation

/// In-memory `NetworkClient` for unit tests and SwiftUI previews.
public final class MockNetworkClient: NetworkClient, @unchecked Sendable {
    public var data: Data
    public var statusCode: Int
    public var error: Error?
    public private(set) var lastRequest: URLRequest?
    public private(set) var requestCount = 0

    public init(
        data: Data = Data(),
        statusCode: Int = 200,
        error: Error? = nil
    ) {
        self.data = data
        self.statusCode = statusCode
        self.error = error
    }

    public func request<T: Decodable>(_ endpoint: URLRequest) async throws -> T {
        lastRequest = endpoint
        requestCount += 1

        if let error {
            if let urlError = error as? URLError {
                throw NetworkError.transportError(urlError)
            }
            if let networkError = error as? NetworkError {
                throw networkError
            }
            throw NetworkError.unexpectedError(error)
        }

        guard (200...299).contains(statusCode) else {
            throw NetworkError.serverError(statusCode: statusCode, data: data)
        }

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch let decodingError as DecodingError {
            throw NetworkError.decodingError(decodingError)
        }
    }
}
