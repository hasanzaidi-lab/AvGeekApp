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

                            FlightTimelineView(
                                departure: timelineInfo(for: flight.departure, label: "Departure"),
                                arrival: timelineInfo(for: flight.arrival, label: "Arrival")
                            )

                            if let route = routeDescription(for: flight) {
                                Text(route)
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

private struct FlightTimelineView: View {
    let departure: SegmentTimelineInfo?
    let arrival: SegmentTimelineInfo?

    var body: some View {
        if departure != nil || arrival != nil {
            HStack(alignment: .top, spacing: 12) {
                if let departure {
                    timelineCard(for: departure)
                }

                if departure != nil && arrival != nil {
                    Image(systemName: "arrow.forward")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .padding(.top, 22)
                }

                if let arrival {
                    timelineCard(for: arrival)
                }
            }
            .padding(.vertical, 2)
        }
    }

    private func timelineCard(for info: SegmentTimelineInfo) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(info.label.uppercased())
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)

            Text(info.time)
                .font(.title3.monospacedDigit())
                .fontWeight(.semibold)

            if let supplement = info.timeSupplement {
                Text(supplement)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            if let primary = info.primaryLocation {
                Text(primary)
                    .font(.subheadline)
            }

            if let secondary = info.secondaryLocation {
                Text(secondary)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Text(info.status)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

private struct SegmentTimelineInfo {
    let label: String
    let time: String
    let timeSupplement: String?
    let status: String
    let primaryLocation: String?
    let secondaryLocation: String?
}

private extension FlightListView {
    func timelineInfo(for segment: FlightSegment, label: String) -> SegmentTimelineInfo? {
        guard let highlightedTime = primaryTime(for: segment) else { return nil }
        let time = Self.renderedTime(from: highlightedTime.time)
        let code = segment.airport?.iata ?? segment.airport?.icao
        let name = segment.airport?.name
        let primaryLocation = code ?? name
        let secondaryLocation = code != nil && name != nil ? name : nil

        return SegmentTimelineInfo(
            label: label,
            time: time,
            timeSupplement: timeSupplement(for: segment.airport?.timeZone),
            status: highlightedTime.status,
            primaryLocation: primaryLocation,
            secondaryLocation: secondaryLocation
        )
    }

    func primaryTime(for segment: FlightSegment) -> (time: FlightTime, status: String)? {
        if let runway = segment.runwayTime {
            return (runway, "Actual runway")
        } else if let revised = segment.revisedTime {
            return (revised, "Updated schedule")
        } else if let scheduled = segment.scheduledTime {
            return (scheduled, "Scheduled")
        }
        return nil
    }

    static func renderedTime(from time: FlightTime) -> String {
        let candidates = [time.local, time.utc]

        for raw in candidates {
            if let clock = clockComponent(from: raw) {
                return clock
            }
        }

        return "--:--"
    }

    static func clockComponent(from raw: String) -> String? {
        guard !raw.isEmpty else { return nil }
        let separators = CharacterSet(charactersIn: "T ")
        let pieces = raw.components(separatedBy: separators).filter { !$0.isEmpty }
        guard let candidate = pieces.last else { return nil }
        let trimmed = candidate
            .replacingOccurrences(of: "Z", with: "")
        let timeAndZone = trimmed.split(whereSeparator: { $0 == "+" || $0 == "-" })
        guard let timePortion = timeAndZone.first else { return nil }
        let components = timePortion.split(separator: ":")
        guard components.count >= 2,
              let hour = Int(components[0]),
              let minute = Int(components[1].prefix(2)) else { return nil }
        return String(format: "%02d:%02d", hour, minute)
    }

    func timeSupplement(for timeZoneIdentifier: String?) -> String? {
        guard let timeZoneIdentifier,
              let timeZone = TimeZone(identifier: timeZoneIdentifier) else { return timeZoneIdentifier }
        return timeZone.abbreviation() ?? timeZone.identifier
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
