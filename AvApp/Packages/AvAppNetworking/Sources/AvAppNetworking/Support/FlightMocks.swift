//
//  FlightMocks.swift
//  AvAppNetworking
//
//  Created by Hasan Zaidi on 9/12/25.
//

#if DEBUG
import AvAppNetworking

extension FlightData {
    public static var mock: FlightData {
        FlightData(
            number: "AA 100",
            status: "Expected",
            codeshareStatus: "IsOperator",
            isCargo: false,
            callSign: "AAL100",
            departure: .mock,
            arrival: .mock,
            airline: Airline(name: "American Airlines", iata: "AA", icao: "AAL"),
            aircraft: Aircraft(model: "Airbus A321", reg: "N123AA", modeS: "A1B2C3")
        )
    }
}

extension FlightSegment {
    public static var mock: FlightSegment {
        FlightSegment(
            scheduledTime: FlightTime(utc: "2025-07-31 14:00Z", local: "2025-07-31 10:00-04:00"),
            revisedTime: nil,
            runwayTime: nil,
            terminal: "B",
            gate: "10",
            runway: "5R",
            baggageBelt: nil,
            quality: ["Basic", "Live"],
            airport: AirportInfo(iata: "MCO", icao: "KMCO", name: "Orlando", timeZone: "America/New_York")
        )
    }
}
#endif
