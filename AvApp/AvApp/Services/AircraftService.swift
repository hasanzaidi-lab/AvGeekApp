//
//  AircraftService.swift
//  AvApp
//
//  Created by Hasan Zaidi on 7/31/25.
//

import Foundation

class AircraftService {
    static let shared = AircraftService()
    
    private let session = URLSession.shared
    private let baseURL = "https://aerodatabox.p.rapidapi.com/aircrafts/reg/"
    private let headers = [
        "x-rapidapi-host": "aerodatabox.p.rapidapi.com",
        "x-rapidapi-key": "31bdfc9f18msh533e951dc1c6231p15dca6jsn722cdc0000a9"
    ]

    func fetchAircraftDetail(registration: String, completion: @escaping (Result<AircraftDetail, Error>) -> Void) {
        guard let url = URL(string: baseURL + registration) else {
            completion(.failure(NSError(domain: "InvalidURL", code: 0)))
            return
        }

        var request = URLRequest(url: url)
        headers.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }

        session.dataTask(with: request) { data, response, error in
            if let error = error {
                return completion(.failure(error))
            }

            guard let data = data else {
                return completion(.failure(NSError(domain: "NoData", code: 0)))
            }

            do {
                let decoded = try JSONDecoder().decode(AircraftDetail.self, from: data)
                completion(.success(decoded))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
