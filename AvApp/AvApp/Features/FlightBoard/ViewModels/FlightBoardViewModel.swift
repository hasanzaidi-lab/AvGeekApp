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

    private let service: any FlightFetching

    init(service: any FlightFetching) {
        self.service = service
        #if DEBUG
        if UITestConfig.isUITesting, !UITestConfig.shouldSimulateNetworkError {
            applyUITestFlights()
        }
        #endif
    }

    func fetchFlights(for airportCode: String) async {
        guard !airportCode.isEmpty else { return }
        isLoading = true
        errorMessage = nil

        #if DEBUG
        if UITestConfig.shouldSimulateNetworkError {
            errorMessage = "Simulated network error"
            isLoading = false
            return
        }
        if UITestConfig.isUITesting {
            applyUITestFlights()
            isLoading = false
            return
        }
        #endif

        do {
            let response = try await service.fetchFlights(for: airportCode)
            departures = response.departures
            arrivals = response.arrivals
        } catch is CancellationError {
            isLoading = false
            return
        } catch {
            if Task.isCancelled {
                isLoading = false
                return
            }
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    #if DEBUG
    private func applyUITestFlights() {
        departures = UITestConfig.flights
        arrivals = Array(UITestConfig.flights.reversed())
    }
    #endif

    func clearError() {
        errorMessage = nil
    }
}
