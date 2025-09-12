//
//  AircraftDetailViewModel.swift
//  AvApp
//
//  Created by Hasan Zaidi on 9/12/25.
//

import Foundation
import AvAppNetworking

@MainActor
class AircraftDetailViewModel: ObservableObject {
    @Published var aircraft: AircraftDetail?
    @Published var isLoading = false
    @Published var error: String?

    func loadAircraftDetail(registration: String) {
        isLoading = true
        error = nil

        Task {
            do {
                // Issue begins here
                let detail = try await AircraftService.shared.fetchAircraftDetail(registration: registration)
                self.aircraft = detail
                self.isLoading = false
            } catch {
                self.error = error.localizedDescription
                self.isLoading = false
            }
        }
    }
}
