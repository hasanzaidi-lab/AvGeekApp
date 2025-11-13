//
//  AircraftDetailCoordinator.swift
//  AvApp
//
//  Created by Hasan Zaidi on 11/13/25.
//

import Foundation

@MainActor
final class AircraftDetailCoordinator: ObservableObject {
    @Published var registration: String
    let viewModel: AircraftDetailViewModel

    init(registration: String, viewModel: AircraftDetailViewModel? = nil) {
        self.registration = registration
        self.viewModel = viewModel ?? AircraftDetailViewModel()
    }

    func onAppear() {
        viewModel.loadAircraftDetail(registration: registration)
    }
}

