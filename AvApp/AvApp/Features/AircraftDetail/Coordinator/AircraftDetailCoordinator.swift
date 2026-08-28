//
//  AircraftDetailCoordinator.swift
//  AvApp
//
//  Created by Hasan Zaidi on 11/13/25.
//

import Foundation
import AvAppNetworking

@MainActor
final class AircraftDetailCoordinator: ObservableObject {
    @Published var registration: String
    let viewModel: AircraftDetailViewModel

    init(registration: String, aircraftService: any AircraftFetching) {
        self.registration = registration
        self.viewModel = AircraftDetailViewModel(service: aircraftService)
    }

    func load() async {
        await viewModel.loadAircraftDetail(registration: registration)
    }
}
