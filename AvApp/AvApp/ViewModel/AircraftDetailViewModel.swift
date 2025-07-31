//
//  AircraftDetailViewModel.swift
//  AvApp
//
//  Created by Hasan Zaidi on 7/31/25.
//

import Foundation

class AircraftDetailViewModel: ObservableObject {
    @Published var aircraft: AircraftDetail?
    @Published var isLoading = false
    @Published var error: String?

    func loadAircraftDetail(registration: String) {
        isLoading = true
        error = nil

        AircraftService.shared.fetchAircraftDetail(registration: registration) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let detail):
                    self.aircraft = detail
                case .failure(let err):
                    self.error = err.localizedDescription
                }
            }
        }
    }
}
