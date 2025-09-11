//
//  NetworkError.swift
//  AvAppNetworking
//
//  Created by Hasan Zaidi on 9/10/25.
//

public enum NetworkError: Error {
    case invalidURL
    case serverError(Int)
    case decodingFailed
    case noData
}
