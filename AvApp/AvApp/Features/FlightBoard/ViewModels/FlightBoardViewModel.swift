//
//  FlightBoardViewModel.swift
//  AvApp
//
//  Created by Hasan Zaidi on 11/13/25.
//

import Foundation
import AvAppNetworking

@MainActor
final class FlightBoardViewModel: ObservableObject {
    @Published private(set) var departures: [FlightData] = []
    @Published private(set) var arrivals: [FlightData] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let service: FlightService

    init(service: FlightService = .shared) {
        self.service = service
    }

    func fetchFlights(for airportCode: String) async {
        guard !airportCode.isEmpty else { return }
        isLoading = true
        errorMessage = nil

        do {
            let response = try await service.fetchFlights(for: airportCode)
            departures = response.departures
            arrivals = response.arrivals
        } catch {
            errorMessage = "Failed to load flight data."
        }

        isLoading = false
    }

    func clearError() {
        errorMessage = nil
    }
}
