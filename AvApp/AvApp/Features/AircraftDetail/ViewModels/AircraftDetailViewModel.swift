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

    private let service: AircraftService

    init(service: AircraftService = .shared) {
        self.service = service
    }

    func loadAircraftDetail(registration: String) {
        guard !registration.isEmpty else { return }
        isLoading = true
        error = nil
        
        #if DEBUG
        if UITestConfig.isUITesting {
            aircraft = UITestConfig.aircraftDetail
            isLoading = false
            return
        }
        #endif

        Task {
            do {
                let detail = try await service.fetchAircraftDetail(registration: registration)
                self.aircraft = detail
            } catch {
                self.error = error.localizedDescription
            }

            self.isLoading = false
        }
    }
}
