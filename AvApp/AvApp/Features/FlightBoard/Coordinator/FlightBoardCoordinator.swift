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

struct AircraftDetailRoute: Hashable {
    let registration: String
}

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
    @Published var departuresPath = NavigationPath()
    @Published var arrivalsPath = NavigationPath()

    let viewModel: FlightBoardViewModel

    var departures: [FlightData] { viewModel.departures }
    var arrivals: [FlightData] { viewModel.arrivals }
    var isLoading: Bool { viewModel.isLoading }
    var errorMessage: String? { viewModel.errorMessage }
    var hasError: Bool { errorMessage != nil }

    private let airportStore: any AirportCodeStoring
    private var cancellables = Set<AnyCancellable>()
    private var autoRefreshTask: Task<Void, Never>?

    init(
        service: any FlightFetching,
        airportStore: any AirportCodeStoring = UserDefaultsAirportStore(),
        airportCode: String? = nil,
        flightSearchText: String = ""
    ) {
        self.viewModel = FlightBoardViewModel(service: service)
        self.airportStore = airportStore
        self.airportCode = airportCode ?? airportStore.load(default: "MCO")
        self.flightSearchText = flightSearchText
        bindViewModel()
    }

    func start() async {
        await fetchFlights()
        startAutoRefresh()
    }

    func stop() {
        autoRefreshTask?.cancel()
        autoRefreshTask = nil
    }

    func fetchFlights(for code: String? = nil) async {
        let normalized = Self.sanitize(code ?? airportCode)
        guard !normalized.isEmpty else { return }
        airportCode = normalized
        airportStore.save(normalized)
        await viewModel.fetchFlights(for: normalized)
    }

    func refresh() async {
        await fetchFlights()
    }

    func dismissError() {
        viewModel.clearError()
    }

    func showAircraftDetail(for flight: FlightData) {
        let route = AircraftDetailRoute(registration: FlightFormatting.aircraftRegistration(for: flight))
        switch selectedTab {
        case .departures:
            departuresPath.append(route)
        case .arrivals:
            arrivalsPath.append(route)
        }
    }

    static func sanitize(_ code: String) -> String {
        code.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    }

    private func startAutoRefresh() {
        autoRefreshTask?.cancel()
        autoRefreshTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(90))
                guard !Task.isCancelled else { return }
                await self?.fetchFlights()
            }
        }
    }

    private func bindViewModel() {
        viewModel.objectWillChange
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
}
