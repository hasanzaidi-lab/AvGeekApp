//
//  FlightListView.swift
//  AvApp
//
//  Created by Hasan Zaidi on 9/12/25.
//

import SwiftUI
import AvAppNetworking

struct FlightListView<Header: View>: View {
    let flights: [FlightData]
    let title: String
    @Binding var searchText: String
    var onRefresh: (() async -> Void)?
    var onSelectFlight: ((FlightData) -> Void)?
    private let header: Header

    init(
        flights: [FlightData],
        title: String,
        searchText: Binding<String>,
        onRefresh: (() async -> Void)? = nil,
        onSelectFlight: ((FlightData) -> Void)? = nil,
        @ViewBuilder header: () -> Header
    ) {
        self.flights = flights
        self.title = title
        self._searchText = searchText
        self.onRefresh = onRefresh
        self.onSelectFlight = onSelectFlight
        self.header = header()
    }

    var body: some View {
        let trimmedSearch = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        let visibleFlights = FlightFormatting.filteredFlights(flights, searchText: searchText)

        List {
            Section {
                header
            }
            .listRowInsets(.init())
            .listRowSeparator(.hidden)

            if visibleFlights.isEmpty {
                emptyState(trimmedSearch: trimmedSearch)
            } else {
                Section {
                    ForEach(visibleFlights) { flight in
                        flightRow(for: flight)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Color.clear)
                    }
                } header: {
                    HStack {
                        Text("Showing \(visibleFlights.count) flight\(visibleFlights.count == 1 ? "" : "s")")
                        Spacer()
                    }
                    .textCase(.none)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.top, 8)
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color(.systemGroupedBackground))
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .automatic), prompt: "Flight # or airline")
        .refreshable {
            await onRefresh?()
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private func flightRow(for flight: FlightData) -> some View {
        let row = FlightRow(flight: flight)

        if let onSelectFlight {
            Button {
                onSelectFlight(flight)
            } label: {
                row
            }
            .buttonStyle(.plain)
        } else {
            row
        }
    }

    private func emptyState(trimmedSearch: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: "sparkle.magnifyingglass")
                .font(.title)
                .foregroundStyle(.secondary)
            if trimmedSearch.isEmpty {
                Text("No flights to show yet.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                Text("Choose an airport and refresh to see live departures and arrivals.")
                    .font(.footnote)
                    .foregroundStyle(.tertiary)
            } else {
                Text("No flights match “\(trimmedSearch)”.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                Text("Try a flight number, airline, or codeshare call sign.")
                    .font(.footnote)
                    .foregroundStyle(.tertiary)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 200)
        .accessibilityIdentifier("flight-list-empty")
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        FlightListView(
            flights: [.mock],
            title: "Departures from MCO",
            searchText: .constant("")
        ) {
            EmptyView()
        }
    }
}
#endif
