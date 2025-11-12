//
//  FlightModels.swift
//  AvAppNetworking
//
//  Created by Hasan Zaidi on 9/12/25.
//

import Foundation

public struct FlightResponse: Decodable {
    public let departures: [FlightData]
    public let arrivals: [FlightData]
}

public struct FlightData: Decodable, Identifiable {
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
}


public struct FlightSegment: Decodable {
    public let scheduledTime: FlightTime?
    public let revisedTime: FlightTime?
    public let terminal: String?
    public let gate: String?
    public let runway: String?
    public let airport: AirportInfo?
}

public struct FlightTime: Decodable {
    public let utc: String
    public let local: String
}

public struct AirportInfo: Decodable {
    public let iata: String?
    public let icao: String?
    public let name: String?
    public let timeZone: String?
}

public struct Airline: Decodable {
    public let name: String
    public let iata: String?
    public let icao: String?
}


public struct Aircraft: Decodable {
    public let model: String
    public let reg: String?
    public let modeS: String?
}
