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
    
    private let service: TrackService
    
    init(service: TrackService = TrackService()) {
        self.service = service
    }
    
    func loadTrack(for icao24: String) {
        guard !icao24.isEmpty else {
            coordinates = []
            errorMessage = "Missing ICAO24 identifier."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let track = try await service.fetchTrack(icao24: icao24)
                self.coordinates = track.path.map(\.coordinate)
                self.callsign = track.callsign?.trimmingCharacters(in: .whitespacesAndNewlines)
                self.lastUpdate = Date(timeIntervalSince1970: track.endTime)
            } catch {
                self.coordinates = []
                self.errorMessage = error.localizedDescription
            }
            
            self.isLoading = false
        }
    }
}
