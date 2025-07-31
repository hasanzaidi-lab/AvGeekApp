//
//  FlightListView.swift
//  AvApp
//
//  Created by Hasan Zaidi on 7/31/25.
//

import SwiftUI

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
    let sampleFlight = FlightData(
        number: "AA 100",
        status: "Expected",
        codeshareStatus: "IsOperator",
        isCargo: false,
        callSign: "AAL100",
        departure: FlightSegment(
            scheduledTime: FlightTime(utc: "2025-07-31 14:00Z", local: "2025-07-31 10:00-04:00"),
            revisedTime: nil,
            terminal: "B",
            gate: "10",
            runway: "5R",
            airport: AirportInfo(iata: "MCO", icao: "KMCO", name: "Orlando", timeZone: "America/New_York")
        ),
        arrival: FlightSegment(
            scheduledTime: FlightTime(utc: "2025-07-31 17:00Z", local: "2025-07-31 13:00-04:00"),
            revisedTime: nil,
            terminal: "3",
            gate: nil,
            runway: nil,
            airport: AirportInfo(iata: "JFK", icao: "KJFK", name: "New York JFK", timeZone: "America/New_York")
        ),
        airline: Airline(name: "American Airlines", iata: "AA", icao: "AAL"),
        aircraft: Aircraft(model: "Airbus A321", reg: "N123AA", modeS: "A1B2C3")
    )

    return NavigationStack {
        FlightListView(flights: [sampleFlight], title: "Departures from MCO")
    }
}
