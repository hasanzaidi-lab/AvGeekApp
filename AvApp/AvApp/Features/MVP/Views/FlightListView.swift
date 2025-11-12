//
//  FlightListView.swift
//  AvApp
//
//  Created by Hasan Zaidi on 9/12/25.
//

import Foundation
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

                    if let timeline = timelineText(for: flight) {
                        Text(timeline)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
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

private extension FlightListView {
    static let iso8601Parser: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withColonSeparatorInTimeZone]
        return formatter
    }()

    static let displayTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter
    }()

    func timelineText(for flight: FlightData) -> String? {
        let normalizedStatus = flight.status.lowercased()

        if normalizedStatus.contains("arriv") {
            return formattedTimeline(label: "Arrival", segment: flight.arrival)
        } else if normalizedStatus.contains("depart") {
            return formattedTimeline(label: "Departure", segment: flight.departure)
        }

        return nil
    }

    func formattedTimeline(label: String, segment: FlightSegment) -> String? {
        guard let time = segment.revisedTime ?? segment.scheduledTime else { return nil }
        return "\(label): \(Self.renderedTime(from: time))"
    }

    static func renderedTime(from time: FlightTime) -> String {
        let candidates = [time.local, time.utc]

        for raw in candidates {
            let isoReady = raw.contains("T") ? raw : raw.replacingOccurrences(of: " ", with: "T")
            if let date = iso8601Parser.date(from: isoReady) {
                return displayTimeFormatter.string(from: date)
            }
        }

        return time.local
    }
}
