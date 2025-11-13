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
    @Binding var searchText: String
    
    var body: some View {
        List {
            if filteredFlights.isEmpty && !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    Text("No flights match “\(searchText.trimmingCharacters(in: .whitespacesAndNewlines))”.")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, minHeight: 200)
            } else {
                ForEach(filteredFlights) { flight in
                    NavigationLink(destination: AircraftDetailView(registration: flight.aircraft?.reg ?? "")) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("\(flight.number) – \(flight.airline.name)")
                                .font(.headline)

                            if let route = routeDescription(for: flight) {
                                Text(route)
                            }

                            if let timeline = timelineText(for: flight) {
                                Text(timeline)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }

                            if let callSign = flight.callSign {
                                Text("Call sign: \(callSign)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }

                            if let aircraftLine = aircraftSummary(for: flight) {
                                Text(aircraftLine)
                            }

                            if let departureDetail = segmentDetails(for: flight.departure, label: "Departure") {
                                Text(departureDetail)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            if let arrivalDetail = segmentDetails(for: flight.arrival, label: "Arrival", includeBaggage: true) {
                                Text(arrivalDetail)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            if let departureQuality = qualityLine(label: "Departure", quality: flight.departure.quality) {
                                Text(departureQuality)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }

                            if let arrivalQuality = qualityLine(label: "Arrival", quality: flight.arrival.quality) {
                                Text(arrivalQuality)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }

                            Text(statusLine(for: flight))
                                .foregroundColor(.gray)

                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .automatic), prompt: "Flight # or airline")
        .navigationTitle(title)
    }
}

#Preview {
    NavigationStack {
        FlightListView(flights: [.mock], title: "Departures from MCO", searchText: .constant(""))
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
        guard let time = segment.runwayTime ?? segment.revisedTime ?? segment.scheduledTime else { return nil }
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

    func routeDescription(for flight: FlightData) -> String? {
        if let destination = airportDescription(from: flight.arrival.airport) {
            return "To: \(destination)"
        } else if let origin = airportDescription(from: flight.departure.airport) {
            return "From: \(origin)"
        }
        return nil
    }

    func airportDescription(from info: AirportInfo?) -> String? {
        guard let info else { return nil }
        let code = info.iata ?? info.icao
        if let name = info.name, let code {
            return "\(name) (\(code))"
        } else if let name = info.name {
            return name
        } else {
            return code
        }
    }

    func aircraftSummary(for flight: FlightData) -> String? {
        guard let aircraft = flight.aircraft else { return nil }
        var parts: [String] = []
        if !aircraft.model.isEmpty {
            parts.append(aircraft.model)
        }
        if let reg = aircraft.reg, !reg.isEmpty {
            parts.append(reg)
        }
        if parts.isEmpty { return nil }
        return "Aircraft: " + parts.joined(separator: " • ")
    }

    func segmentDetails(for segment: FlightSegment, label: String, includeBaggage: Bool = false) -> String? {
        var parts: [String] = []
        if let terminal = segment.terminal, !terminal.isEmpty {
            parts.append("Terminal \(terminal)")
        }
        if let gate = segment.gate, !gate.isEmpty {
            parts.append("Gate \(gate)")
        }
        if let runway = segment.runway, !runway.isEmpty {
            parts.append("Runway \(runway)")
        }
        if includeBaggage, let belt = segment.baggageBelt, !belt.isEmpty {
            parts.append("Baggage \(belt)")
        }
        guard !parts.isEmpty else { return nil }
        return "\(label): " + parts.joined(separator: " • ")
    }

    func qualityLine(label: String, quality: [String]?) -> String? {
        guard let quality, !quality.isEmpty else { return nil }
        return "\(label) data: \(quality.joined(separator: ", "))"
    }

    func statusLine(for flight: FlightData) -> String {
        var parts: [String] = ["Status: \(flight.status)"]
        let codeshare = friendlyCodeshareStatus(flight.codeshareStatus)
        if !codeshare.isEmpty {
            parts.append("Codeshare: \(codeshare)")
        }
        if flight.isCargo {
            parts.append("Cargo flight")
        }
        return parts.joined(separator: " • ")
    }

    func friendlyCodeshareStatus(_ raw: String) -> String {
        guard !raw.isEmpty else { return raw }
        return raw
            .replacingOccurrences(of: "(?<=[a-z0-9])([A-Z])", with: " $1", options: .regularExpression)
            .replacingOccurrences(of: "_", with: " ")
            .capitalized
    }

    var filteredFlights: [FlightData] {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return flights }
        return flights.filter { matches($0, searchTerm: trimmed) }
    }

    func matches(_ flight: FlightData, searchTerm: String) -> Bool {
        flight.number.localizedCaseInsensitiveContains(searchTerm)
        || flight.airline.name.localizedCaseInsensitiveContains(searchTerm)
        || (flight.callSign?.localizedCaseInsensitiveContains(searchTerm) ?? false)
    }
}
