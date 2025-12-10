import CoreLocation
import Foundation
import AvAppNetworking

#if DEBUG
enum UITestConfig {
    static var isUITesting: Bool {
        let arguments = ProcessInfo.processInfo.arguments
        return arguments.contains("-ui_testing_screenshots")
        || arguments.contains("-ui_testing")
        || arguments.contains("-FASTLANE_SNAPSHOT")
    }

    static var flights: [FlightData] {
        [
            .mock(
                number: "AA 100",
                status: "Departed",
                callSign: "AAL100",
                departure: .mock(
                    scheduledUTC: "2025-07-31 14:05Z",
                    scheduledLocal: "2025-07-31 10:05-04:00",
                    runwayUTC: "2025-07-31 14:15Z",
                    terminal: "B",
                    gate: "10",
                    runway: "5R",
                    airportIata: "MCO",
                    airportIcao: "KMCO",
                    airportName: "Orlando",
                    timeZone: "America/New_York"
                ),
                arrival: .mock(
                    scheduledUTC: "2025-07-31 16:45Z",
                    scheduledLocal: "2025-07-31 12:45-04:00",
                    terminal: "C",
                    gate: "72",
                    runway: "22L",
                    baggageBelt: "6",
                    airportIata: "JFK",
                    airportIcao: "KJFK",
                    airportName: "New York JFK",
                    timeZone: "America/New_York"
                ),
                airlineName: "American Airlines",
                airlineIata: "AA",
                airlineIcao: "AAL",
                aircraftModel: "Airbus A321",
                aircraftReg: "N123AA",
                aircraftModeS: "a1b2c3"
            ),
            .mock(
                number: "DL 82",
                status: "Expected",
                callSign: "DAL82",
                departure: .mock(
                    scheduledUTC: "2025-07-31 18:20Z",
                    scheduledLocal: "2025-07-31 14:20-04:00",
                    terminal: "S",
                    gate: "A14",
                    runway: "9L",
                    airportIata: "ATL",
                    airportIcao: "KATL",
                    airportName: "Atlanta",
                    timeZone: "America/New_York"
                ),
                arrival: .mock(
                    scheduledUTC: "2025-07-31 21:05Z",
                    scheduledLocal: "2025-07-31 14:05-07:00",
                    terminal: "B",
                    gate: "24",
                    runway: "24R",
                    airportIata: "LAX",
                    airportIcao: "KLAX",
                    airportName: "Los Angeles",
                    timeZone: "America/Los_Angeles"
                ),
                airlineName: "Delta Air Lines",
                airlineIata: "DL",
                airlineIcao: "DAL",
                aircraftModel: "Boeing 757-200",
                aircraftReg: "N826DX",
                aircraftModeS: "a4c5d6"
            ),
            .mock(
                number: "UA 2205",
                status: "Boarding",
                callSign: "UAL2205",
                departure: .mock(
                    scheduledUTC: "2025-07-31 19:10Z",
                    scheduledLocal: "2025-07-31 14:10-05:00",
                    terminal: "1",
                    gate: "C15",
                    runway: "28C",
                    airportIata: "ORD",
                    airportIcao: "KORD",
                    airportName: "Chicago O'Hare",
                    timeZone: "America/Chicago"
                ),
                arrival: .mock(
                    scheduledUTC: "2025-07-31 22:40Z",
                    scheduledLocal: "2025-07-31 15:40-07:00",
                    terminal: "3",
                    gate: "E7",
                    runway: "8R",
                    baggageBelt: "12",
                    airportIata: "SFO",
                    airportIcao: "KSFO",
                    airportName: "San Francisco",
                    timeZone: "America/Los_Angeles"
                ),
                airlineName: "United Airlines",
                airlineIata: "UA",
                airlineIcao: "UAL",
                aircraftModel: "Boeing 737 MAX 9",
                aircraftReg: "N27531",
                aircraftModeS: "b7e8f9"
            )
        ]
    }

    static var aircraftDetail: AircraftDetail {
        .mock
    }

    static var track: AircraftTrack {
        .mock
    }

    static var trackCoordinates: [CLLocationCoordinate2D] {
        track.path.map(\.coordinate)
    }
}
#endif
