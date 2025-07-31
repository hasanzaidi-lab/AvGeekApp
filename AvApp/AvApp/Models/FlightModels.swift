//
//  FlightResponse.swift
//  AvApp
//
//  Created by Hasan Zaidi on 7/31/25.
//

import Foundation

struct FlightResponse: Decodable {
    let departures: [FlightData]
    let arrivals: [FlightData]
}

struct FlightData: Decodable, Identifiable {
    let id = UUID() // local ID for SwiftUI
    let number: String
    let status: String
    let codeshareStatus: String
    let isCargo: Bool
    let callSign: String?
    
    let departure: FlightSegment
    let arrival: FlightSegment
    let airline: Airline
    let aircraft: Aircraft?
}

struct FlightSegment: Decodable {
    let scheduledTime: FlightTime?
    let revisedTime: FlightTime?
    let terminal: String?
    let gate: String?
    let runway: String?
    let airport: AirportInfo?
}

struct FlightTime: Decodable {
    let utc: String
    let local: String
}

struct AirportInfo: Decodable {
    let iata: String?
    let icao: String?
    let name: String?
    let timeZone: String?
}

struct Airline: Decodable {
    let name: String
    let iata: String?
    let icao: String?
}


struct Aircraft: Decodable {
    let model: String
    let reg: String?
    let modeS: String?
}
