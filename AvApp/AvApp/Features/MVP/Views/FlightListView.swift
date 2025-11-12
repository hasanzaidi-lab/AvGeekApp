//
//  FlightListView.swift
//  AvApp
//
//  Created by Hasan Zaidi on 9/12/25.
//

import SwiftUI
import AvAppNetworking

struct FlightListView: View {
    let flights: [FlightData]
    let title: String
    
    var body: some View {
        List(flights) { flight in
            NavigationLink(destination: AircraftDetailView(registration: flight.aircraft?.reg ?? "")) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(flight.number) – \(flight.airline.name ?? "Unknown Airline")")
                        .font(.headline)

                    if let arrival = flight.arrival.airport?.name {
                        Text("To: \(arrival)")
                    }

                    Text("Status: \(flight.status)")
                        .foregroundColor(.gray)

                }
            }
        }
        .navigationTitle(title)
    }
}

#Preview {
    NavigationStack {
        FlightListView(flights: [.mock], title: "Departures from MCO")
    }
}
