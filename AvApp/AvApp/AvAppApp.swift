//
//  AvAppApp.swift
//  AvApp
//
//  Created by Hasan Zaidi on 7/31/25.
//

import SwiftUI

@main
struct AvAppApp: App {
    @StateObject private var session = AppSession()

    var body: some Scene {
        WindowGroup {
            FlightBoardView(coordinator: session.flightBoardCoordinator)
                .environment(\.appDependencies, session.dependencies)
        }
    }
}
