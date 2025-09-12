//
//  AircraftDetail.swift
//  AvAppNetworking
//
//  Created by Hasan Zaidi on 9/12/25.
//

import Foundation

public struct AircraftDetail: Codable {
    public let registration: String
    public let model: String?
    public let hex: String?
    public let ageYears: Double?
    public let airline: String?
    public let owner: String?
    public let msn: String?
    public let productionLine: String?
}
