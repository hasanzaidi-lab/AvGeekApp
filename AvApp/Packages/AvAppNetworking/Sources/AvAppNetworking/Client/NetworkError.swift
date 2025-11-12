//
//  NetworkError.swift
//  AvAppNetworking
//
//  Created by Hasan Zaidi on 9/10/25.
//

import Foundation

public enum NetworkError: Error, LocalizedError {
    case invalidURL(String)
    case invalidResponse                          // <-- new case
    case transportError(URLError)
    case serverError(statusCode: Int, data: Data?)
    case decodingError(DecodingError)
    case unexpectedError(Error)
    
    public var errorDescription: String? {
        switch self {
        case .invalidURL(let urlString):
            return "Invalid URL: \(urlString)"
        case .invalidResponse:
            return "Did not receive a valid HTTP response."
        case .transportError(let urlError):
            return "Network transport error: \(urlError.localizedDescription)"
        case .serverError(let code, _):
            return "Server returned status code \(code)."
        case .decodingError(let decodingError):
            return "Failed to decode response: \(decodingError.localizedDescription)"
        case .unexpectedError(let error):
            return "Unexpected error: \(error.localizedDescription)"
        }
    }
}
