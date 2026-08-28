//
//  AircraftDetailViewModel.swift
//  AvApp
//
//  Created by Hasan Zaidi on 9/12/25.
//

import Foundation
import AvAppNetworking

@MainActor
final class AircraftDetailViewModel: ObservableObject {
    @Published var aircraft: AircraftDetail?
    @Published var isLoading = false
    @Published var error: String?

    private let service: any AircraftFetching

    init(service: any AircraftFetching) {
        self.service = service
    }

    func loadAircraftDetail(registration: String) async {
        guard !registration.isEmpty else {
            error = "This flight has no aircraft registration to look up."
            return
        }
        isLoading = true
        error = nil

        #if DEBUG
        if UITestConfig.isUITesting {
            aircraft = UITestConfig.aircraftDetail
            isLoading = false
            return
        }
        #endif

        do {
            aircraft = try await service.fetchAircraftDetail(registration: registration)
        } catch is CancellationError {
            isLoading = false
            return
        } catch {
            if Task.isCancelled {
                isLoading = false
                return
            }
            self.error = error.localizedDescription
        }

        isLoading = false
    }
}
