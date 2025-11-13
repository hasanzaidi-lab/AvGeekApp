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
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                TextField("IATA code (e.g. MCO)", text: $code)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled(true)
                    .submitLabel(.search)
                    .onSubmit { Task { await onSubmit(nil) } }

                Button(action: onRefresh) {
                    Image(systemName: "arrow.clockwise")
                }
                .buttonStyle(.borderedProminent)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(suggestedCodes, id: \.self) { suggestion in
                        Button(suggestion) {
                            code = suggestion
                            Task { await onSubmit(suggestion) }
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }
        }
        .padding()
        .background(.thinMaterial)
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

