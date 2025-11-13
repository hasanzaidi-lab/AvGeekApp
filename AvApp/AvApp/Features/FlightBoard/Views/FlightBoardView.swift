//
//  FlightBoardView.swift
//  AvApp
//
//  Created by Hasan Zaidi on 11/13/25.
//

import SwiftUI
import AvAppNetworking

struct FlightBoardView: View {
    @StateObject private var coordinator = FlightBoardCoordinator()

    var body: some View {
        VStack(spacing: 0) {
            FlightBoardAirportSearchBar(
                code: $coordinator.airportCode,
                suggestedCodes: FlightBoardAirportSearchBar.defaultSuggestions,
                onSubmit: { await coordinator.fetchFlights(for: $0) },
                onRefresh: coordinator.refresh
            )

            TabView(selection: $coordinator.selectedTab) {
                FlightListContainer(
                    title: "Departures from \(coordinator.airportCode)",
                    flights: coordinator.departures,
                    searchText: $coordinator.flightSearchText
                )
                .tag(FlightBoardCoordinator.Tab.departures)
                .tabItem { Label("Departures", systemImage: FlightBoardCoordinator.Tab.departures.systemImage) }

                FlightListContainer(
                    title: "Arrivals to \(coordinator.airportCode)",
                    flights: coordinator.arrivals,
                    searchText: $coordinator.flightSearchText
                )
                .tag(FlightBoardCoordinator.Tab.arrivals)
                .tabItem { Label("Arrivals", systemImage: FlightBoardCoordinator.Tab.arrivals.systemImage) }
            }
        }
        .task { coordinator.onAppear() }
        .overlay(alignment: .bottom) {
            if coordinator.isLoading {
                ProgressView("Refreshing flights...")
                    .padding()
                    .background(.thinMaterial)
                    .cornerRadius(12)
                    .padding()
            }
        }
        .alert(
            "Something went wrong",
            isPresented: Binding(
                get: { coordinator.hasError },
                set: { if !$0 { coordinator.dismissError() } }
            ),
            actions: {
                Button("Retry") { coordinator.refresh() }
                Button("Dismiss", role: .cancel) { coordinator.dismissError() }
            },
            message: {
                Text(coordinator.errorMessage ?? "")
            }
        )
    }
}

private struct FlightListContainer: View {
    let title: String
    let flights: [FlightData]
    @Binding var searchText: String

    var body: some View {
        NavigationStack {
            FlightListView(
                flights: flights,
                title: title,
                searchText: $searchText
            )
        }
    }
}

#Preview { FlightBoardView() }
