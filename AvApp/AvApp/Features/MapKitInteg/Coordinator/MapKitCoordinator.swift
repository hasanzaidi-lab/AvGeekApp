//
//  MapKitCoordinator.swift
//  AvApp
//
//  Created by Hasan Zaidi on 11/14/25.
//

import Foundation
import AvAppNetworking

@MainActor
final class MapKitCoordinator: ObservableObject {
    @Published var icao24: String
    let viewModel: MapKitViewModel

    init(icao24: String, trackService: any TrackFetching) {
        self.icao24 = icao24
        self.viewModel = MapKitViewModel(service: trackService)
    }

    func loadTrack(for icao24: String? = nil) async {
        if let newValue = icao24, !newValue.isEmpty {
            self.icao24 = newValue
        }
        guard !self.icao24.isEmpty else { return }
        await viewModel.loadTrack(for: self.icao24)
    }
}
