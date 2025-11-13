//
//  ContentView.swift
//  AvApp
//
//  Created by Hasan Zaidi on 9/12/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = FlightViewModel()
    @State private var airportCode = "MCO"
    @State private var flightSearchText = ""
    @State private var selectedTab = 0

    var body: some View {
        VStack(spacing: 0) {
            airportSearchBar

            TabView(selection: $selectedTab) {

                // Departures tab
                NavigationStack {
                    FlightListView(
                        flights: viewModel.departures,
                        title: "Departures from \(airportCode)",
                        searchText: $flightSearchText
                    )
                }
                .tabItem { Label("Departures", systemImage: "airplane.departure") }
                .tag(0)

                // Arrivals tab
                NavigationStack {
                    FlightListView(
                        flights: viewModel.arrivals,
                        title: "Arrivals to \(airportCode)",
                        searchText: $flightSearchText
                    )
                }
                .tabItem { Label("Arrivals", systemImage: "airplane.arrival") }
                .tag(1)
            }
        }
        .task {
            await fetchFlights()
        }
    }
}

#Preview { ContentView() }

private extension ContentView {
    var airportSearchBar: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                TextField("IATA code (e.g. MCO)", text: $airportCode)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled(true)
                    .submitLabel(.search)
                    .onSubmit { Task { await fetchFlights() } }

                Button {
                    Task { await fetchFlights() }
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .buttonStyle(.borderedProminent)
                .tint(.accentColor)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(airportSuggestions, id: \.self) { code in
                        Button(code) {
                            airportCode = code
                            Task { await fetchFlights(for: code) }
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }
        }
        .padding()
        .background(.thinMaterial)
    }

    var airportSuggestions: [String] { ["JFK", "LAX", "SFO", "ORD", "DFW", "ATL", "MCO"] }

    @MainActor
    func fetchFlights(for code: String? = nil) async {
        let normalized = sanitizedAirportCode(code ?? airportCode)
        guard !normalized.isEmpty else { return }
        await viewModel.fetchFlights(for: normalized)
        airportCode = normalized
    }

    func sanitizedAirportCode(_ code: String) -> String {
        code
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .uppercased()
    }
}
