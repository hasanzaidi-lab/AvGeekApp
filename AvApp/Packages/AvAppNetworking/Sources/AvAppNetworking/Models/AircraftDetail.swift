//
//  AircraftDetail.swift
//  AvAppNetworking
//
//  Created by Hasan Zaidi on 9/12/25.
//

import Foundation

public struct AircraftDetail: Codable {
    public let id: Int?
    public let registration: String
    public let isActive: Bool?
    public let isFreighter: Bool?
    public let isVerified: Bool?
    public let model: String?
    public let modelCode: String?
    public let typeName: String?
    public let productionLine: String?
    public let airlineName: String?
    public let owner: String?
    public let icaoHex: String?
    public let iataCodeShort: String?
    public let icaoCode: String?
    public let serialNumber: String?
    public let seatCount: Int?
    public let engineCount: Int?
    public let engineType: String?
    public let registrationHistoryCount: Int?
    public let rolloutDate: String?
    public let firstFlightDate: String?
    public let deliveryDate: String?
    public let registrationDate: String?
    public let ageYears: Double?

    enum CodingKeys: String, CodingKey {
        case id
        case registration = "reg"
        case isActive = "active"
        case isFreighter
        case isVerified = "verified"
        case model
        case modelCode
        case typeName
        case productionLine
        case airlineName
        case owner
        case icaoHex = "hexIcao"
        case iataCodeShort
        case icaoCode
        case serialNumber = "serial"
        case seatCount = "numSeats"
        case engineCount = "numEngines"
        case engineType
        case registrationHistoryCount = "numRegistrations"
        case rolloutDate
        case firstFlightDate
        case deliveryDate
        case registrationDate
        case ageYears
    }
}
