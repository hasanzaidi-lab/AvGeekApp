import SwiftUI
import AvAppNetworking

struct FlightRow: View {
    let flight: FlightData

    var body: some View {
        let departure = FlightFormatting.timelineInfo(for: flight.departure, label: "Departure")
        let arrival = FlightFormatting.timelineInfo(for: flight.arrival, label: "Arrival")
        let departureQuality = FlightFormatting.qualityLine(label: "Departure", quality: flight.departure.quality)
        let arrivalQuality = FlightFormatting.qualityLine(label: "Arrival", quality: flight.arrival.quality)

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
                if let route = FlightFormatting.routeDescription(for: flight) {
                    Label(route, systemImage: "map")
                        .font(.callout)
                }

                HStack(spacing: 8) {
                    if let aircraftLine = FlightFormatting.aircraftSummary(for: flight) {
                        infoChip(text: aircraftLine, systemImage: "airplane")
                    }
                    if let callSign = flight.callSign {
                        infoChip(text: "Call sign \(callSign)", systemImage: "antenna.radiowaves.left.and.right")
                    }
                }

                HStack(spacing: 8) {
                    if let departureDetail = FlightFormatting.segmentDetails(for: flight.departure, label: "Departure") {
                        detailChip(text: departureDetail, systemImage: "airplane.departure")
                    }
                    if let arrivalDetail = FlightFormatting.segmentDetails(for: flight.arrival, label: "Arrival", includeBaggage: true) {
                        detailChip(text: arrivalDetail, systemImage: "airplane.arrival")
                    }
                }

                if let qualityText = combinedQuality(departure: departureQuality, arrival: arrivalQuality) {
                    Label(qualityText, systemImage: "scope")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Label(FlightFormatting.statusLine(for: flight), systemImage: "info.circle")
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
        .accessibilityLabel(FlightFormatting.accessibilityLabel(for: flight))
    }

    private var statusBadge: some View {
        Text(FlightFormatting.friendlyStatus(flight.status))
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

    private func combinedQuality(departure: String?, arrival: String?) -> String? {
        switch (departure, arrival) {
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
}

#if DEBUG
#Preview {
    FlightRow(flight: .mock)
        .padding()
}
#endif
