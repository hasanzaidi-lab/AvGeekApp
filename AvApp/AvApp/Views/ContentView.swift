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
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {

            // Departures tab
            NavigationStack {
                FlightListView(flights: viewModel.departures,
                               title: "Departures from \(airportCode)")
                    .navigationTitle("Flights")
                    .searchable(text: $airportCode,
                                placement: .navigationBarDrawer(displayMode: .automatic),
                                prompt: "IATA code (e.g. MCO)")
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled(true)
                    .onSubmit(of: .search) {
                        Task { await viewModel.fetchFlights(for: airportCode.trimmingCharacters(in: .whitespacesAndNewlines)) }
                    }
                    .searchSuggestions {
                        ForEach(["JFK","LAX","SFO","ORD","DFW","ATL","MCO"], id: \.self) { code in
                            Button(code) {
                                airportCode = code
                                Task { await viewModel.fetchFlights(for: code) }
                            }
                            .searchCompletion(code)
                        }
                    }
            }
            .tabItem { Label("Departures", systemImage: "airplane.departure") }
            .tag(0)

            // Arrivals tab
            NavigationStack {
                FlightListView(flights: viewModel.arrivals,
                               title: "Arrivals to \(airportCode)")
                    .navigationTitle("Flights")
                    .searchable(text: $airportCode,
                                placement: .navigationBarDrawer(displayMode: .automatic),
                                prompt: "IATA code (e.g. MCO)")
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled(true)
                    .onSubmit(of: .search) {
                        Task { await viewModel.fetchFlights(for: airportCode.trimmingCharacters(in: .whitespacesAndNewlines)) }
                    }
            }
            .tabItem { Label("Arrivals", systemImage: "airplane.arrival") }
            .tag(1)
        }
        .task {
            await viewModel.fetchFlights(for: airportCode)
        }
    }
}

#Preview { ContentView() }
