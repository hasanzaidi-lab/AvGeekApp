//
//  FlightViewModel.swift
//  AvApp
//
//  Created by Hasan Zaidi on 9/12/25.
//

import Foundation
import AvAppNetworking

@MainActor
class FlightViewModel: ObservableObject {
    @Published var departures: [FlightData] = []
    @Published var arrivals: [FlightData] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func fetchFlights(for airportCode: String) async {
        isLoading = true
        errorMessage = nil

        do {
            let response = try await FlightService.shared.fetchFlights(for: airportCode)
            self.departures = response.departures
            self.arrivals = response.arrivals
        } catch {
            print("❌ Error fetching flights:", error)
            self.errorMessage = "Failed to load flight data."
        }

        isLoading = false
    }
}
