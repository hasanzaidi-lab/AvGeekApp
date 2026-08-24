//
//  MapKitCoordinator.swift
//  AvApp
//
//  Created by Hasan Zaidi on 11/14/25.
//

import Foundation

@MainActor
final class MapKitCoordinator: ObservableObject {
    @Published var icao24: String
    let viewModel: MapKitViewModel

    init(
        icao24: String,
        viewModel: MapKitViewModel? = nil
    ) {
        self.icao24 = icao24
        if let viewModel {
            self.viewModel = viewModel
        } else {
            self.viewModel = MapKitViewModel()
        }
    }

    func onAppear() {
        loadTrack()
    }

    func loadTrack(for icao24: String? = nil) {
        if let newValue = icao24, !newValue.isEmpty {
            self.icao24 = newValue
        }
        guard !self.icao24.isEmpty else { return }
        viewModel.loadTrack(for: self.icao24)
    }
}

