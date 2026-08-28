import XCTest
@testable import AvApp
import AvAppNetworking

@MainActor
final class FlightBoardViewModelTests: XCTestCase {
    func testSuccessPopulatesDeparturesAndArrivals() async {
        let service = MockFlightService(
            response: FlightResponse(departures: [.mock], arrivals: [.mock])
        )
        let viewModel = FlightBoardViewModel(service: service)

        await viewModel.fetchFlights(for: "MCO")

        XCTAssertEqual(viewModel.departures.count, 1)
        XCTAssertEqual(viewModel.arrivals.count, 1)
        XCTAssertEqual(viewModel.departures.first?.number, "AA 100")
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.isLoading)
    }

    func testErrorSetsUserFacingMessage() async {
        let service = MockFlightService(error: NetworkError.serverError(statusCode: 500, data: nil))
        let viewModel = FlightBoardViewModel(service: service)

        await viewModel.fetchFlights(for: "JFK")

        XCTAssertTrue(viewModel.departures.isEmpty)
        XCTAssertEqual(viewModel.errorMessage, NetworkError.serverError(statusCode: 500, data: nil).localizedDescription)
        XCTAssertFalse(viewModel.isLoading)
    }

    func testClearErrorRemovesMessage() async {
        let service = MockFlightService(error: NetworkError.missingAPIKey)
        let viewModel = FlightBoardViewModel(service: service)

        await viewModel.fetchFlights(for: "LAX")
        XCTAssertNotNil(viewModel.errorMessage)

        viewModel.clearError()
        XCTAssertNil(viewModel.errorMessage)
    }

    func testEmptyAirportCodeDoesNotFetch() async {
        let service = RecordingFlightService()
        let viewModel = FlightBoardViewModel(service: service)

        await viewModel.fetchFlights(for: "")

        XCTAssertNil(service.lastAirportCode)
        XCTAssertFalse(viewModel.isLoading)
    }
}

@MainActor
final class FlightBoardCoordinatorTests: XCTestCase {
    func testSanitizeTrimsAndUppercasesAirportCodes() {
        XCTAssertEqual(FlightBoardCoordinator.sanitize(" mco "), "MCO")
        XCTAssertEqual(FlightBoardCoordinator.sanitize("jfk"), "JFK")
        XCTAssertEqual(FlightBoardCoordinator.sanitize("   "), "")
    }

    func testFetchPersistsSanitizedAirportCode() async {
        let store = MockAirportStore(stored: "MCO")
        let service = RecordingFlightService()
        let coordinator = FlightBoardCoordinator(
            service: service,
            airportStore: store,
            airportCode: "mco"
        )

        await coordinator.fetchFlights(for: " jfk ")

        XCTAssertEqual(coordinator.airportCode, "JFK")
        XCTAssertEqual(store.stored, "JFK")
        XCTAssertEqual(service.lastAirportCode, "JFK")
        XCTAssertEqual(coordinator.departures.count, 1)
    }

    func testEmptyAirportCodeDoesNotOverwriteExistingValue() async {
        let store = MockAirportStore(stored: "MCO")
        let coordinator = FlightBoardCoordinator(
            service: MockFlightService(),
            airportStore: store,
            airportCode: "MCO"
        )

        await coordinator.fetchFlights(for: "   ")

        XCTAssertEqual(coordinator.airportCode, "MCO")
        XCTAssertEqual(store.stored, "MCO")
    }

    func testTabStateDefaultsToDeparturesAndCanSwitch() {
        let coordinator = FlightBoardCoordinator(
            service: MockFlightService(),
            airportStore: MockAirportStore(),
            airportCode: "MCO"
        )

        XCTAssertEqual(coordinator.selectedTab, .departures)
        XCTAssertEqual(FlightBoardCoordinator.Tab.departures.title, "Departures")
        XCTAssertEqual(FlightBoardCoordinator.Tab.arrivals.title, "Arrivals")

        coordinator.selectedTab = .arrivals
        XCTAssertEqual(coordinator.selectedTab, .arrivals)
    }

    func testShowAircraftDetailPushesRouteOnSelectedTab() {
        let coordinator = FlightBoardCoordinator(
            service: MockFlightService(),
            airportStore: MockAirportStore(),
            airportCode: "MCO"
        )

        XCTAssertTrue(coordinator.departuresPath.isEmpty)
        coordinator.showAircraftDetail(for: .mock)
        XCTAssertEqual(coordinator.departuresPath.count, 1)

        coordinator.selectedTab = .arrivals
        coordinator.showAircraftDetail(for: .mock(number: "DL 82", status: "Expected", aircraftModel: nil))
        XCTAssertEqual(coordinator.arrivalsPath.count, 1)
    }
}

@MainActor
final class AircraftDetailViewModelTests: XCTestCase {
    func testEmptyRegistrationSetsError() async {
        let viewModel = AircraftDetailViewModel(service: MockAircraftService())

        await viewModel.loadAircraftDetail(registration: "")

        XCTAssertEqual(viewModel.error, "This flight has no aircraft registration to look up.")
        XCTAssertNil(viewModel.aircraft)
        XCTAssertFalse(viewModel.isLoading)
    }

    func testSuccessLoadsAircraft() async {
        let viewModel = AircraftDetailViewModel(service: MockAircraftService(detail: .mock))

        await viewModel.loadAircraftDetail(registration: "N123AA")

        XCTAssertEqual(viewModel.aircraft?.registration, "N123AA")
        XCTAssertNil(viewModel.error)
    }
}

final class FlightFormattingTests: XCTestCase {
    func testClockComponentParsesLocalAndUTCStrings() {
        XCTAssertEqual(FlightFormatting.clockComponent(from: "2025-07-31 10:05-04:00"), "10:05")
        XCTAssertEqual(FlightFormatting.clockComponent(from: "2025-07-31T14:15Z"), "14:15")
        XCTAssertNil(FlightFormatting.clockComponent(from: ""))
    }

    func testFriendlyStatusAndSearchFiltering() {
        XCTAssertEqual(FlightFormatting.friendlyStatus("expected_departure"), "Expected Departure")
        XCTAssertEqual(FlightFormatting.friendlyCodeshareStatus("IsOperator"), "Is Operator")

        let flights = [FlightData.mock, FlightData.mock(number: "DL 82", status: "Expected", airlineName: "Delta Air Lines")]
        XCTAssertEqual(FlightFormatting.filteredFlights(flights, searchText: "delta").count, 1)
        XCTAssertEqual(FlightFormatting.filteredFlights(flights, searchText: "  ").count, 2)
    }

    func testAircraftRegistrationFallsBackToEmptyString() {
        XCTAssertEqual(FlightFormatting.aircraftRegistration(for: .mock), "N123AA")
        XCTAssertEqual(
            FlightFormatting.aircraftRegistration(for: .mock(number: "XX 1", status: "Unknown", aircraftModel: nil)),
            ""
        )
    }
}

final class MockAirportStore: AirportCodeStoring, @unchecked Sendable {
    var stored: String?

    init(stored: String? = nil) {
        self.stored = stored
    }

    func load(default defaultCode: String) -> String {
        stored ?? defaultCode
    }

    func save(_ code: String) {
        stored = code
    }
}

final class RecordingFlightService: FlightFetching, @unchecked Sendable {
    var lastAirportCode: String?
    var response: FlightResponse

    init(response: FlightResponse = FlightResponse(departures: [.mock], arrivals: [.mock])) {
        self.response = response
    }

    func fetchFlights(for airportCode: String) async throws -> FlightResponse {
        lastAirportCode = airportCode
        return response
    }
}
