//
//  FlightBoardAirportSearchBar.swift
//  AvApp
//
//  Created by Hasan Zaidi on 11/13/25.
//

import SwiftUI

struct FlightBoardAirportSearchBar: View {
    @Binding var code: String
    let suggestedCodes: [String]
    let onSubmit: (String?) async -> Void
    let onRefresh: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.12))
                    Image(systemName: "airplane.departure")
                        .foregroundStyle(.blue)
                }
                .frame(width: 42, height: 42)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Airport lookup")
                        .font(.headline)
                    Text("Use a three-letter IATA code. We will fetch live data for that terminal.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button(action: onRefresh) {
                    Label("Refresh", systemImage: "arrow.clockwise")
                        .labelStyle(.titleAndIcon)
                }
                .buttonStyle(.borderedProminent)
            }

            HStack(spacing: 10) {
                Image(systemName: "mappin.and.ellipse")
                    .foregroundStyle(.secondary)

                TextField("Try MCO, LHR, DXB…", text: $code)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled(true)
                    .submitLabel(.search)
                    .onSubmit { Task { await onSubmit(nil) } }

                Button {
                    Task { await onSubmit(nil) }
                } label: {
                    Text("Search")
                        .fontWeight(.semibold)
                }
                .buttonStyle(.bordered)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Quick picks")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(suggestedCodes, id: \.self) { suggestion in
                            Button {
                                code = suggestion
                                Task { await onSubmit(suggestion) }
                            } label: {
                                Text(suggestion)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.blue.opacity(0.2))
                        }
                    }
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 8)
    }
}

extension FlightBoardAirportSearchBar {
    static let defaultSuggestions = ["JFK", "LAX", "SFO", "ORD", "DFW", "ATL", "MCO"]
}

#Preview {
    FlightBoardAirportSearchBar(
        code: .constant("MCO"),
        suggestedCodes: FlightBoardAirportSearchBar.defaultSuggestions,
        onSubmit: { _ in },
        onRefresh: {}
    )
}
