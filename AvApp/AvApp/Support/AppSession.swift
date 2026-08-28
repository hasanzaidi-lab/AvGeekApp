import SwiftUI
import AvAppNetworking

@MainActor
final class AppSession: ObservableObject {
    let dependencies: AppDependencies
    let flightBoardCoordinator: FlightBoardCoordinator

    init(dependencies: AppDependencies = .live) {
        self.dependencies = dependencies
        self.flightBoardCoordinator = FlightBoardCoordinator(service: dependencies.flightService)
    }
}
