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
        ZStack {
            LinearGradient(
                colors: [Color.blue.opacity(0.12), Color(.systemBackground)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            TabView(selection: $coordinator.selectedTab) {
                FlightListContainer(
                    title: "Departures from \(coordinator.airportCode)",
                    flights: coordinator.departures,
                    searchText: $coordinator.flightSearchText
                ) {
                    headerContent
                }
                .tag(FlightBoardCoordinator.Tab.departures)
                .tabItem { Label("Departures", systemImage: FlightBoardCoordinator.Tab.departures.systemImage) }

                FlightListContainer(
                    title: "Arrivals to \(coordinator.airportCode)",
                    flights: coordinator.arrivals,
                    searchText: $coordinator.flightSearchText
                ) {
                    headerContent
                }
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

private struct FlightListContainer<Header: View>: View {
    let title: String
    let flights: [FlightData]
    @Binding var searchText: String
    @ViewBuilder var header: () -> Header

    var body: some View {
        NavigationStack {
            FlightListView(
                flights: flights,
                title: title,
                searchText: $searchText,
                header: header
            )
        }
    }
}

private extension FlightBoardView {
    @ViewBuilder
    var headerContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Live Flight Board")
                    .font(.largeTitle.bold())
                Text("Enter an airport to see real-time departures and arrivals. Pull to refresh anytime.")
                    .foregroundStyle(.secondary)
                    .font(.callout)
            }

            FlightBoardAirportSearchBar(
                code: $coordinator.airportCode,
                suggestedCodes: FlightBoardAirportSearchBar.defaultSuggestions,
                onSubmit: { await coordinator.fetchFlights(for: $0) },
                onRefresh: coordinator.refresh
            )
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

#Preview { FlightBoardView() }
