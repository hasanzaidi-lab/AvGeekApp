//
//  FlightBoardCoordinator.swift
//  AvApp
//
//  Created by Hasan Zaidi on 11/13/25.
//

import Combine
import Foundation
import SwiftUI
import AvAppNetworking

@MainActor
final class FlightBoardCoordinator: ObservableObject {
    enum Tab: Hashable, CaseIterable {
        case departures
        case arrivals

        var title: String {
            switch self {
            case .departures: return "Departures"
            case .arrivals: return "Arrivals"
            }
        }

        var systemImage: String {
            switch self {
            case .departures: return "airplane.departure"
            case .arrivals: return "airplane.arrival"
            }
        }
    }

    @Published var selectedTab: Tab = .departures
    @Published var airportCode: String
    @Published var flightSearchText: String
    @Published private(set) var departures: [FlightData] = []
    @Published private(set) var arrivals: [FlightData] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let viewModel: FlightBoardViewModel
    private var cancellables = Set<AnyCancellable>()

    init(
        service: FlightService = .shared,
        airportCode: String = "MCO",
        flightSearchText: String = ""
    ) {
        self.viewModel = FlightBoardViewModel(service: service)
        self.airportCode = airportCode
        self.flightSearchText = flightSearchText
        bindViewModel()
    }

    func onAppear() {
        Task { await fetchFlights() }
    }

    func fetchFlights(for code: String? = nil) async {
        let normalized = sanitize(code ?? airportCode)
        guard !normalized.isEmpty else { return }
        airportCode = normalized
        await viewModel.fetchFlights(for: normalized)
    }

    func refresh() {
        Task { await fetchFlights() }
    }

    var hasError: Bool { errorMessage != nil }

    func dismissError() {
        viewModel.clearError()
    }

    private func sanitize(_ code: String) -> String {
        code.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    }

    private func bindViewModel() {
        viewModel.$departures
            .receive(on: RunLoop.main)
            .assign(to: &$departures)

        viewModel.$arrivals
            .receive(on: RunLoop.main)
            .assign(to: &$arrivals)

        viewModel.$isLoading
            .receive(on: RunLoop.main)
            .assign(to: &$isLoading)

        viewModel.$errorMessage
            .receive(on: RunLoop.main)
            .assign(to: &$errorMessage)
    }
}
