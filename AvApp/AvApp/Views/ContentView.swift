//
//  ContentView.swift
//  AvApp
//
//  Created by Hasan Zaidi on 7/31/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = FlightViewModel()
    @State private var airportCode: String = "MCO"
    @State private var selectedTab = 0

    var body: some View {
        VStack {
            // Airport IATA Input
            HStack {
                TextField("Enter IATA code (e.g. MCO)", text: $airportCode)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.allCharacters)
                    .disableAutocorrection(true)
                Button("Search") {
                    Task {
                        await viewModel.fetchFlights(for: airportCode)
                    }
                }
            }
            .padding()

            // Tabs for Departures / Arrivals
            TabView(selection: $selectedTab) {
                NavigationStack {
                    FlightListView(flights: viewModel.departures, title: "Departures from \(airportCode)")
                }
                .tabItem {
                    Label("Departures", systemImage: "airplane.departure")
                }
                .tag(0)

                NavigationStack {
                    FlightListView(flights: viewModel.arrivals, title: "Arrivals to \(airportCode)")
                }
                .tabItem {
                    Label("Arrivals", systemImage: "airplane.arrival")
                }
                .tag(1)
            }
        }
        .task {
            await viewModel.fetchFlights(for: airportCode)
        }
    }
}

#Preview {
    ContentView()
}
