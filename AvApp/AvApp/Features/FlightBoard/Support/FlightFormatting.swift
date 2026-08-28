import Foundation
import AvAppNetworking

struct SegmentTimelineInfo: Equatable {
    let label: String
    let time: String
    let timeSupplement: String?
    let status: String
    let primaryLocation: String?
    let secondaryLocation: String?
}

enum FlightFormatting {
    static func timelineInfo(for segment: FlightSegment, label: String) -> SegmentTimelineInfo? {
        guard let highlightedTime = primaryTime(for: segment) else { return nil }
        let time = renderedTime(from: highlightedTime.time)
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

    static func primaryTime(for segment: FlightSegment) -> (time: FlightTime, status: String)? {
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
        for raw in [time.local, time.utc] {
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
        let trimmed = candidate.replacingOccurrences(of: "Z", with: "")
        let timeAndZone = trimmed.split(whereSeparator: { $0 == "+" || $0 == "-" })
        guard let timePortion = timeAndZone.first else { return nil }
        let components = timePortion.split(separator: ":")
        guard components.count >= 2,
              let hour = Int(components[0]),
              let minute = Int(components[1].prefix(2)) else { return nil }
        return String(format: "%02d:%02d", hour, minute)
    }

    static func timeSupplement(for timeZoneIdentifier: String?) -> String? {
        guard let timeZoneIdentifier,
              let timeZone = TimeZone(identifier: timeZoneIdentifier) else { return timeZoneIdentifier }
        return timeZone.abbreviation() ?? timeZone.identifier
    }

    static func routeDescription(for flight: FlightData) -> String? {
        if let destination = airportDescription(from: flight.arrival.airport) {
            return "To: \(destination)"
        } else if let origin = airportDescription(from: flight.departure.airport) {
            return "From: \(origin)"
        }
        return nil
    }

    static func airportDescription(from info: AirportInfo?) -> String? {
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

    static func aircraftSummary(for flight: FlightData) -> String? {
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

    static func segmentDetails(for segment: FlightSegment, label: String, includeBaggage: Bool = false) -> String? {
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

    static func qualityLine(label: String, quality: [String]?) -> String? {
        guard let quality, !quality.isEmpty else { return nil }
        return "\(label) data: \(quality.joined(separator: ", "))"
    }

    static func statusLine(for flight: FlightData) -> String {
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

    static func friendlyStatus(_ raw: String) -> String {
        raw
            .replacingOccurrences(of: "_", with: " ")
            .replacingOccurrences(of: "(?<=[a-z0-9])([A-Z])", with: " $1", options: .regularExpression)
            .capitalized
    }

    static func friendlyCodeshareStatus(_ raw: String) -> String {
        guard !raw.isEmpty else { return raw }
        return raw
            .replacingOccurrences(of: "(?<=[a-z0-9])([A-Z])", with: " $1", options: .regularExpression)
            .replacingOccurrences(of: "_", with: " ")
            .capitalized
    }

    static func accessibilityLabel(for flight: FlightData) -> String {
        let route = [flight.departure.airport?.iata, flight.arrival.airport?.iata]
            .compactMap { $0 }
            .joined(separator: " to ")
        return "\(flight.number), \(flight.airline.name), \(flight.status), \(route)"
    }

    static func filteredFlights(_ flights: [FlightData], searchText: String) -> [FlightData] {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return flights }
        return flights.filter { matches($0, searchTerm: trimmed) }
    }

    static func matches(_ flight: FlightData, searchTerm: String) -> Bool {
        flight.number.localizedCaseInsensitiveContains(searchTerm)
        || flight.airline.name.localizedCaseInsensitiveContains(searchTerm)
        || (flight.callSign?.localizedCaseInsensitiveContains(searchTerm) ?? false)
    }

    static func aircraftRegistration(for flight: FlightData) -> String {
        flight.aircraft?.reg?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }
}
