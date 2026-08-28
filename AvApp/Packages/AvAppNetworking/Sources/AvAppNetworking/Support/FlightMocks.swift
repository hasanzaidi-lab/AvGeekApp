//
//  FlightMocks.swift
//  AvAppNetworking
//
//  Created by Hasan Zaidi on 9/12/25.
//

import CoreLocation

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

    public static func mock(
        number: String,
        status: String,
        codeshareStatus: String = "IsOperator",
        isCargo: Bool = false,
        callSign: String? = nil,
        departure: FlightSegment = .mock,
        arrival: FlightSegment = .mock,
        airlineName: String = "American Airlines",
        airlineIata: String? = "AA",
        airlineIcao: String? = "AAL",
        aircraftModel: String? = "Airbus A321",
        aircraftReg: String? = "N123AA",
        aircraftModeS: String? = "A1B2C3"
    ) -> FlightData {
        let airline = Airline(name: airlineName, iata: airlineIata, icao: airlineIcao)
        let aircraft: Aircraft?
        if let aircraftModel {
            aircraft = Aircraft(model: aircraftModel, reg: aircraftReg, modeS: aircraftModeS)
        } else {
            aircraft = nil
        }

        return FlightData(
            number: number,
            status: status,
            codeshareStatus: codeshareStatus,
            isCargo: isCargo,
            callSign: callSign,
            departure: departure,
            arrival: arrival,
            airline: airline,
            aircraft: aircraft
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

    public static func mock(
        scheduledUTC: String = "2025-07-31 14:00Z",
        scheduledLocal: String = "2025-07-31 10:00-04:00",
        revisedUTC: String? = nil,
        runwayUTC: String? = nil,
        terminal: String? = "B",
        gate: String? = "10",
        runway: String? = "5R",
        baggageBelt: String? = nil,
        quality: [String]? = ["Basic", "Live"],
        airportIata: String? = "MCO",
        airportIcao: String? = "KMCO",
        airportName: String? = "Orlando",
        timeZone: String? = "America/New_York"
    ) -> FlightSegment {
        FlightSegment(
            scheduledTime: FlightTime(utc: scheduledUTC, local: scheduledLocal),
            revisedTime: revisedUTC.map { FlightTime(utc: $0, local: $0) },
            runwayTime: runwayUTC.map { FlightTime(utc: $0, local: $0) },
            terminal: terminal,
            gate: gate,
            runway: runway,
            baggageBelt: baggageBelt,
            quality: quality,
            airport: AirportInfo(
                iata: airportIata,
                icao: airportIcao,
                name: airportName,
                timeZone: timeZone
            )
        )
    }
}

extension AircraftDetail {
    public static var mock: AircraftDetail {
        AircraftDetail(
            id: 1,
            registration: "N123AA",
            isActive: true,
            isFreighter: false,
            isVerified: true,
            model: "Airbus A321-231",
            modelCode: "A321",
            typeName: "A321",
            productionLine: "Airbus A320neo",
            airlineName: "American Airlines",
            owner: "American Airlines",
            icaoHex: "a1b2c3",
            iataCodeShort: "32B",
            icaoCode: "A321",
            serialNumber: "12345",
            seatCount: 190,
            engineCount: 2,
            engineType: "CFM LEAP-1A",
            registrationHistoryCount: 2,
            rolloutDate: "2019-04-01",
            firstFlightDate: "2019-05-14",
            deliveryDate: "2019-06-01",
            registrationDate: "2019-06-10",
            ageYears: 5.5
        )
    }
}

extension AircraftTrack {
    public static var mock: AircraftTrack {
        let now = Date()
        let oneMinute: TimeInterval = 60
        let start = now.addingTimeInterval(-30 * oneMinute).timeIntervalSince1970
        let end = now.timeIntervalSince1970

        return AircraftTrack(
            icao24: "a1b2c3",
            startTime: start,
            endTime: end,
            callsign: "AAL100",
            path: [
                TrackPoint(timestamp: start, latitude: 28.4179, longitude: -81.3244, baroAltitude: 1000, trueTrack: 180, onGround: false),
                TrackPoint(timestamp: start + 10 * oneMinute, latitude: 28.6000, longitude: -81.1000, baroAltitude: 9000, trueTrack: 170, onGround: false),
                TrackPoint(timestamp: end, latitude: 29.0000, longitude: -80.7000, baroAltitude: 14000, trueTrack: 145, onGround: false)
            ]
        )
    }
}
