//
//  FlightModels.swift
//  AvAppNetworking
//
//  Created by Hasan Zaidi on 9/12/25.
//

import Foundation

public struct FlightResponse: Decodable, Sendable {
    public let departures: [FlightData]
    public let arrivals: [FlightData]

    public init(departures: [FlightData], arrivals: [FlightData]) {
        self.departures = departures
        self.arrivals = arrivals
    }
}

public struct FlightData: Decodable, Identifiable, Sendable {
    public let id = UUID()
    public let number: String
    public let status: String
    public let codeshareStatus: String
    public let isCargo: Bool
    public let callSign: String?
    public let departure: FlightSegment
    public let arrival: FlightSegment
    public let airline: Airline
    public let aircraft: Aircraft?

    public init(
        number: String,
        status: String,
        codeshareStatus: String,
        isCargo: Bool,
        callSign: String?,
        departure: FlightSegment,
        arrival: FlightSegment,
        airline: Airline,
        aircraft: Aircraft?
    ) {
        self.number = number
        self.status = status
        self.codeshareStatus = codeshareStatus
        self.isCargo = isCargo
        self.callSign = callSign
        self.departure = departure
        self.arrival = arrival
        self.airline = airline
        self.aircraft = aircraft
    }

    enum CodingKeys: String, CodingKey {
        case number
        case status
        case codeshareStatus
        case isCargo
        case callSign
        case departure
        case arrival
        case airline
        case aircraft
    }
}

public struct FlightSegment: Decodable, Sendable {
    public let scheduledTime: FlightTime?
    public let revisedTime: FlightTime?
    public let runwayTime: FlightTime?
    public let terminal: String?
    public let gate: String?
    public let runway: String?
    public let baggageBelt: String?
    public let quality: [String]?
    public let airport: AirportInfo?

    public init(
        scheduledTime: FlightTime?,
        revisedTime: FlightTime?,
        runwayTime: FlightTime?,
        terminal: String?,
        gate: String?,
        runway: String?,
        baggageBelt: String?,
        quality: [String]?,
        airport: AirportInfo?
    ) {
        self.scheduledTime = scheduledTime
        self.revisedTime = revisedTime
        self.runwayTime = runwayTime
        self.terminal = terminal
        self.gate = gate
        self.runway = runway
        self.baggageBelt = baggageBelt
        self.quality = quality
        self.airport = airport
    }
}

public struct FlightTime: Decodable, Sendable {
    public let utc: String
    public let local: String

    public init(utc: String, local: String) {
        self.utc = utc
        self.local = local
    }
}

public struct AirportInfo: Decodable, Sendable {
    public let iata: String?
    public let icao: String?
    public let name: String?
    public let timeZone: String?

    public init(iata: String?, icao: String?, name: String?, timeZone: String?) {
        self.iata = iata
        self.icao = icao
        self.name = name
        self.timeZone = timeZone
    }
}

public struct Airline: Decodable, Sendable {
    public let name: String
    public let iata: String?
    public let icao: String?

    public init(name: String, iata: String?, icao: String?) {
        self.name = name
        self.iata = iata
        self.icao = icao
    }
}

public struct Aircraft: Decodable, Sendable {
    public let model: String
    public let reg: String?
    public let modeS: String?

    public init(model: String, reg: String?, modeS: String?) {
        self.model = model
        self.reg = reg
        self.modeS = modeS
    }
}
