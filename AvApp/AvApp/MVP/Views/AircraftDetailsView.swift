//
//  AircraftDetailsView.swift
//  AvApp
//
//  Created by Hasan Zaidi on 9/12/25.
//

// Views/AircraftDetailView.swift

import SwiftUI

struct AircraftDetailView: View {
    let registration: String
    @StateObject private var viewModel = AircraftDetailViewModel()

    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView("Loading...")
            } else if let aircraft = viewModel.aircraft {
                List {
                    Text("Registration: \(aircraft.registration)")
                    if let model = aircraft.model {
                        Text("Model: \(model)")
                    }
                    if let airline = aircraft.airline {
                        Text("Airline: \(airline)")
                    }
                    if let age = aircraft.ageYears {
                        Text("Age: \(age, specifier: "%.1f") years")
                    }
                    if let msn = aircraft.msn {
                        Text("MSN: \(msn)")
                    }
                }
            } else if let error = viewModel.error {
                Text("Error:::: \(error)")
                    .foregroundColor(.red)
            }
        }
        .navigationTitle("Aircraft Info")
        .onAppear {
            viewModel.loadAircraftDetail(registration: registration)
        }
    }
}

#Preview {
    NavigationStack {
        AircraftDetailView(registration: "N664NK")
    }
}
