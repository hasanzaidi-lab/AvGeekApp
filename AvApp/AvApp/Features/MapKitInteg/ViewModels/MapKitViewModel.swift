//
//  MapKitViewModel.swift
//  AvApp
//
//  Created by Hasan Zaidi on 11/11/25.
//

import MapKit
import Foundation
import CoreLocation
import AvAppNetworking

@MainActor
final class MapKitViewModel: ObservableObject {
    @Published private(set) var coordinates: [CLLocationCoordinate2D] = []
    @Published private(set) var callsign: String?
    @Published private(set) var lastUpdate: Date?
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?

    private let service: any TrackFetching

    init(service: any TrackFetching) {
        self.service = service
    }

    func loadTrack(for icao24: String) async {
        guard !icao24.isEmpty else {
            coordinates = []
            errorMessage = "Missing ICAO24 identifier."
            return
        }

        isLoading = true
        errorMessage = nil

        #if DEBUG
        if UITestConfig.isUITesting {
            let track = UITestConfig.track
            coordinates = UITestConfig.trackCoordinates
            callsign = track.callsign?.trimmingCharacters(in: .whitespacesAndNewlines)
            lastUpdate = Date(timeIntervalSince1970: track.endTime)
            isLoading = false
            return
        }
        #endif

        do {
            let track = try await service.fetchTrack(icao24: icao24)
            coordinates = track.path.map(\.coordinate)
            callsign = track.callsign?.trimmingCharacters(in: .whitespacesAndNewlines)
            lastUpdate = Date(timeIntervalSince1970: track.endTime)
        } catch is CancellationError {
            isLoading = false
            return
        } catch {
            if Task.isCancelled {
                isLoading = false
                return
            }
            coordinates = []
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
