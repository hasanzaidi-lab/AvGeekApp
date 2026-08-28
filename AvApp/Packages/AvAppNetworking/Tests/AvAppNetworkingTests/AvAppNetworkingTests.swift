import XCTest
@testable import AvAppNetworking

final class AvAppNetworkingTests: XCTestCase {
    func testFlightResponseFixtureDecodes() throws {
        let data = try fixtureData(named: "flights")
        let response = try JSONDecoder().decode(FlightResponse.self, from: data)

        XCTAssertEqual(response.departures.count, 1)
        XCTAssertEqual(response.arrivals.count, 1)
        XCTAssertEqual(response.departures.first?.number, "AA 100")
        XCTAssertEqual(response.departures.first?.aircraft?.reg, "N123AA")
        XCTAssertEqual(response.arrivals.first?.airline.iata, "DL")
    }

    func testAircraftDetailFixtureDecodes() throws {
        let data = try fixtureData(named: "aircraft")
        let detail = try JSONDecoder().decode(AircraftDetail.self, from: data)

        XCTAssertEqual(detail.registration, "N123AA")
        XCTAssertEqual(detail.icaoHex, "a1b2c3")
        XCTAssertEqual(detail.seatCount, 190)
        XCTAssertEqual(detail.isActive, true)
    }

    func testFlightServiceUsesAirportCodeAndAPIHeaders() async throws {
        let data = try fixtureData(named: "flights")
        let client = MockNetworkClient(data: data)
        let service = FlightService(client: client, apiKey: "test-key")

        let response = try await service.fetchFlights(for: " mco ")

        XCTAssertEqual(response.departures.count, 1)
        XCTAssertEqual(client.requestCount, 1)
        XCTAssertEqual(client.lastRequest?.value(forHTTPHeaderField: "X-RapidAPI-Key"), "test-key")
        XCTAssertEqual(client.lastRequest?.value(forHTTPHeaderField: "X-RapidAPI-Host"), "aerodatabox.p.rapidapi.com")
        XCTAssertTrue(client.lastRequest?.url?.absoluteString.contains("/MCO?") ?? false)
    }

    func testFlightServiceThrowsWhenAPIKeyMissing() async {
        let service = FlightService(client: MockNetworkClient(), apiKey: "")

        do {
            _ = try await service.fetchFlights(for: "MCO")
            XCTFail("Expected missingAPIKey")
        } catch NetworkError.missingAPIKey {
            // expected
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testAircraftServiceMapsServerErrors() async {
        let client = MockNetworkClient(data: Data(), statusCode: 403)
        let service = AircraftService(client: client, apiKey: "test-key")

        do {
            _ = try await service.fetchAircraftDetail(registration: "N123AA")
            XCTFail("Expected serverError")
        } catch let error as NetworkError {
            if case .serverError(let statusCode, _) = error {
                XCTAssertEqual(statusCode, 403)
            } else {
                XCTFail("Unexpected NetworkError: \(error)")
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testMockNetworkClientMapsTransportErrors() async {
        let client = MockNetworkClient(error: URLError(.notConnectedToInternet))
        let service = FlightService(client: client, apiKey: "test-key")

        do {
            _ = try await service.fetchFlights(for: "JFK")
            XCTFail("Expected transportError")
        } catch NetworkError.transportError {
            // expected
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testNetworkErrorUserFacingDescriptions() {
        XCTAssertTrue(NetworkError.missingAPIKey.localizedDescription.contains("RapidAPI"))
        XCTAssertTrue(NetworkError.serverError(statusCode: 403, data: nil).localizedDescription.contains("403"))
        XCTAssertTrue(NetworkError.serverError(statusCode: 429, data: nil).localizedDescription.contains("Too many"))
    }

    func testTrackServiceBuildsOpenSkyURL() async throws {
        let payload = """
        {"icao24":"a1b2c3","startTime":1,"endTime":2,"callsign":"AAL100","path":[[1,28.4,-81.3,1000,180,false]]}
        """.data(using: .utf8)!
        let client = MockNetworkClient(data: payload)
        let service = TrackService(client: client)

        let track = try await service.fetchTrack(icao24: "A1B2C3")

        XCTAssertEqual(track.icao24, "a1b2c3")
        XCTAssertEqual(track.path.count, 1)
        XCTAssertEqual(client.lastRequest?.url?.host, "opensky-network.org")
        XCTAssertTrue(client.lastRequest?.url?.query?.contains("icao24=a1b2c3") ?? false)
    }

    private func fixtureData(named name: String) throws -> Data {
        guard let url = Bundle.module.url(forResource: name, withExtension: "json") else {
            throw XCTSkip("Missing fixture \(name).json")
        }
        return try Data(contentsOf: url)
    }
}
