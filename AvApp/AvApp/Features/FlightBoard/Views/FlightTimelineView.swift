import SwiftUI

struct FlightTimelineView: View {
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
