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
    private let header: Header

    init(
        flights: [FlightData],
        title: String,
        searchText: Binding<String>,
        @ViewBuilder header: () -> Header
    ) {
        self.flights = flights
        self.title = title
        self._searchText = searchText
        self.header = header()
    }
    
    var body: some View {
        let trimmedSearch = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        List {
            Section {
                header
            }
            .listRowInsets(.init())
            .listRowSeparator(.hidden)

            if filteredFlights.isEmpty {
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
            } else {
                Section {
                    ForEach(filteredFlights) { flight in
                        NavigationLink(destination: AircraftDetailView(registration: flight.aircraft?.reg ?? "")) {
                            FlightRow(
                                flight: flight,
                                departure: timelineInfo(for: flight.departure, label: "Departure"),
                                arrival: timelineInfo(for: flight.arrival, label: "Arrival"),
                                route: routeDescription(for: flight),
                                callSign: flight.callSign,
                                aircraftLine: aircraftSummary(for: flight),
                                departureDetail: segmentDetails(for: flight.departure, label: "Departure"),
                                arrivalDetail: segmentDetails(for: flight.arrival, label: "Arrival", includeBaggage: true),
                                departureQuality: qualityLine(label: "Departure", quality: flight.departure.quality),
                                arrivalQuality: qualityLine(label: "Arrival", quality: flight.arrival.quality),
                                statusLine: statusLine(for: flight)
                            )
                            .accessibilityIdentifier("flight-row")
                        }
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                    }
                } header: {
                    HStack {
                        Text("Showing \(filteredFlights.count) flight\(filteredFlights.count == 1 ? "" : "s")")
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
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

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

private struct FlightRow: View {
    let flight: FlightData
    let departure: SegmentTimelineInfo?
    let arrival: SegmentTimelineInfo?
    let route: String?
    let callSign: String?
    let aircraftLine: String?
    let departureDetail: String?
    let arrivalDetail: String?
    let departureQuality: String?
    let arrivalQuality: String?
    let statusLine: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(flight.number)
                        .font(.title3.weight(.semibold))
                    Text(flight.airline.name)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                statusBadge
            }
            .accessibilityElement(children: .contain)
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color(.secondarySystemBackground))
                )

            FlightTimelineView(
                departure: departure,
                arrival: arrival
            )

            VStack(alignment: .leading, spacing: 8) {
                if let route {
                    Label(route, systemImage: "map")
                        .font(.callout)
                }

                HStack(spacing: 8) {
                    if let aircraftLine {
                        infoChip(text: aircraftLine, systemImage: "airplane")
                    }
                    if let callSign {
                        infoChip(text: "Call sign \(callSign)", systemImage: "antenna.radiowaves.left.and.right")
                    }
                }

                HStack(spacing: 8) {
                    if let departureDetail {
                        detailChip(text: departureDetail, systemImage: "airplane.departure")
                    }
                    if let arrivalDetail {
                        detailChip(text: arrivalDetail, systemImage: "airplane.arrival")
                    }
                }

                if let qualityText {
                    Label(qualityText, systemImage: "scope")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Label(statusLine, systemImage: "info.circle")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.primary.opacity(0.05))
        )
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("flight-row")
    }

    private var statusBadge: some View {
        Text(friendlyStatus(flight.status))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(statusTint.opacity(0.18))
            )
            .foregroundStyle(statusTint)
            .font(.footnote.weight(.semibold))
    }

    private var statusTint: Color {
        let status = flight.status.lowercased()
        if status.contains("cancel") { return .red }
        if status.contains("divert") { return .orange }
        if status.contains("delay") { return .orange }
        if status.contains("land") { return .green }
        if status.contains("depart") || status.contains("active") { return .blue }
        return .blue
    }

    private var qualityText: String? {
        switch (departureQuality, arrivalQuality) {
        case let (departure?, arrival?):
            return "\(departure); \(arrival)"
        case let (departure?, nil):
            return departure
        case let (nil, arrival?):
            return arrival
        default:
            return nil
        }
    }

    private func infoChip(text: String, systemImage: String) -> some View {
        Label(text, systemImage: systemImage)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(Color.primary.opacity(0.05))
            )
            .font(.footnote)
    }

    private func detailChip(text: String, systemImage: String) -> some View {
        Label(text, systemImage: systemImage)
            .font(.caption)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(Color.primary.opacity(0.03))
            )
            .foregroundStyle(.secondary)
    }

    private func friendlyStatus(_ raw: String) -> String {
        raw
            .replacingOccurrences(of: "_", with: " ")
            .replacingOccurrences(of: "(?<=[a-z0-9])([A-Z])", with: " $1", options: .regularExpression)
            .capitalized
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
