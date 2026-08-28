//
//  NetworkError.swift
//  AvAppNetworking
//
//  Created by Hasan Zaidi on 9/10/25.
//

import Foundation

public enum NetworkError: Error, LocalizedError {
    case missingAPIKey
    case invalidURL(String)
    case invalidResponse
    case transportError(URLError)
    case serverError(statusCode: Int, data: Data?)
    case decodingError(DecodingError)
    case unexpectedError(Error)

    public var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "Missing RapidAPI key. Add it to Secrets.plist or the RAPIDAPI_KEY environment variable."
        case .invalidURL(let urlString):
            return "Invalid URL: \(urlString)"
        case .invalidResponse:
            return "Did not receive a valid HTTP response."
        case .transportError(let urlError):
            return "Network transport error: \(urlError.localizedDescription)"
        case .serverError(let code, _) where code == 403:
            return "Access denied (403). Check your RapidAPI key and quota."
        case .serverError(let code, _) where code == 429:
            return "Too many requests. Please wait and try again."
        case .serverError(let code, _):
            return "Server returned status code \(code)."
        case .decodingError:
            return "Could not read the server response."
        case .unexpectedError(let error):
            return "Unexpected error: \(error.localizedDescription)"
        }
    }
}
