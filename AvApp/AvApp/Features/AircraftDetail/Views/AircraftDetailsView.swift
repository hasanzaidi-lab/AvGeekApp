//
//  AircraftDetailsView.swift
//  AvApp
//
//  Created by Hasan Zaidi on 9/12/25.
//

// Views/AircraftDetailView.swift

import SwiftUI

struct AircraftDetailView: View {
    @StateObject private var coordinator: AircraftDetailCoordinator
    @ObservedObject private var viewModel: AircraftDetailViewModel

    init(registration: String) {
        let coordinator = AircraftDetailCoordinator(registration: registration)
        _coordinator = StateObject(wrappedValue: coordinator)
        _viewModel = ObservedObject(wrappedValue: coordinator.viewModel)
    }

    var body: some View {
        Group {
            if viewModel.isLoading {
                VStack {
                    ProgressView("Loading...")
                }
            } else if let aircraft = viewModel.aircraft {
                List {
                    Section("Summary") {
                        detailRow("Registration", value: aircraft.registration)
                        detailRow("Airline", value: aircraft.airlineName)
                        detailRow("Type", value: aircraft.typeName ?? aircraft.model)
                        detailRow("Model code", value: aircraft.modelCode)
                        detailRow("Production line", value: aircraft.productionLine)
                        detailRow("Seats", value: aircraft.seatCount.map(String.init))
                        detailRow("Engines", value: engineDescription(count: aircraft.engineCount, type: aircraft.engineType))
                        detailRow("Age", value: ageDescription(from: aircraft.ageYears))
                        detailRow("Active", value: yesNo(aircraft.isActive))
                        detailRow("Freighter", value: yesNo(aircraft.isFreighter))
                        detailRow("Verified data", value: yesNo(aircraft.isVerified))
                    }

                    Section("Identifiers") {
                        detailRow("ICAO hex", value: aircraft.icaoHex)
                        detailRow("IATA code", value: aircraft.iataCodeShort)
                        detailRow("ICAO code", value: aircraft.icaoCode)
                        detailRow("Serial number", value: aircraft.serialNumber)
                        detailRow("Owner", value: aircraft.owner)
                        detailRow("Record ID", value: aircraft.id.map(String.init))
                        detailRow("Registrations on file", value: aircraft.registrationHistoryCount.map(String.init))
                    }

                    Section("Timeline") {
                        detailRow("Rollout", value: formatted(dateString: aircraft.rolloutDate))
                        detailRow("First flight", value: formatted(dateString: aircraft.firstFlightDate))
                        detailRow("Delivery", value: formatted(dateString: aircraft.deliveryDate))
                        detailRow("Registered", value: formatted(dateString: aircraft.registrationDate))
                    }
                }
                .listStyle(.insetGrouped)
            } else if let error = viewModel.error {
                VStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    Text(error)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "airplane")
                        .foregroundColor(.secondary)
                    Text("Select a flight to load aircraft details.")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationTitle("Aircraft Info")
        .onAppear(perform: coordinator.onAppear)
    }
}

#Preview {
    NavigationStack {
        AircraftDetailView(registration: "N664NK")
    }
}

private extension AircraftDetailView {
    @ViewBuilder
    func detailRow(_ title: String, value: String?) -> some View {
        if let value, !value.isEmpty {
            HStack {
                Text(title)
                Spacer()
                Text(value)
                    .foregroundColor(.secondary)
            }
        }
    }

    func yesNo(_ value: Bool?) -> String? {
        value.map { $0 ? "Yes" : "No" }
    }

    func ageDescription(from years: Double?) -> String? {
        guard let years else { return nil }
        return String(format: "%.1f years", years)
    }

    func engineDescription(count: Int?, type: String?) -> String? {
        switch (count, type) {
        case let (count?, type?):
            return "\(count) × \(type)"
        case let (count?, nil):
            return "\(count)"
        case let (nil, type?):
            return type
        default:
            return nil
        }
    }

    func formatted(dateString: String?) -> String? {
        guard let value = dateString,
              let date = Self.dateParser.date(from: value) else {
            return dateString
        }
        return Self.dateDisplayFormatter.string(from: date)
    }

    static let dateParser: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()

    static let dateDisplayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
}
