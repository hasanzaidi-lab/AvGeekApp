//
//  TrackModels.swift
//  AvAppNetworking
//
//  Created by Hasan Zaidi on 11/26/25.
//

import Foundation
import CoreLocation

public struct AircraftTrack: Decodable, Sendable {
    public let icao24: String
    public let startTime: TimeInterval
    public let endTime: TimeInterval
    public let callsign: String?
    public let path: [TrackPoint]
    
    public init(
        icao24: String,
        startTime: TimeInterval,
        endTime: TimeInterval,
        callsign: String?,
        path: [TrackPoint]
    ) {
        self.icao24 = icao24
        self.startTime = startTime
        self.endTime = endTime
        self.callsign = callsign
        self.path = path
    }

    enum CodingKeys: String, CodingKey {
        case icao24
        case startTime
        case endTime
        case callsign
        case path
    }
}

public struct TrackPoint: Decodable, Identifiable, Sendable {
    public let timestamp: TimeInterval
    public let latitude: Double
    public let longitude: Double
    public let baroAltitude: Double?
    public let trueTrack: Double?
    public let onGround: Bool?
    
    public var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    public var id: TimeInterval {
        timestamp
    }
    
    public init(timestamp: TimeInterval, latitude: Double, longitude: Double, baroAltitude: Double?, trueTrack: Double?, onGround: Bool?) {
        self.timestamp = timestamp
        self.latitude = latitude
        self.longitude = longitude
        self.baroAltitude = baroAltitude
        self.trueTrack = trueTrack
        self.onGround = onGround
    }
    
    public init(from decoder: Decoder) throws {
        if let keyed = try? decoder.container(keyedBy: Keys.self) {
            timestamp = try keyed.decode(TimeInterval.self, forKey: .time)
            latitude = try keyed.decode(Double.self, forKey: .latitude)
            longitude = try keyed.decode(Double.self, forKey: .longitude)
            baroAltitude = try keyed.decodeIfPresent(Double.self, forKey: .baroAltitude)
            trueTrack = try keyed.decodeIfPresent(Double.self, forKey: .trueTrack)
            onGround = try keyed.decodeIfPresent(Bool.self, forKey: .onGround)
            return
        }
        
        var unkeyed = try decoder.unkeyedContainer()
        timestamp = try unkeyed.decode(TimeInterval.self)
        latitude = try unkeyed.decode(Double.self)
        longitude = try unkeyed.decode(Double.self)
        baroAltitude = try? unkeyed.decode(Double.self)
        trueTrack = try? unkeyed.decode(Double.self)
        onGround = try? unkeyed.decode(Bool.self)
    }
    
    private enum Keys: String, CodingKey {
        case time
        case latitude
        case longitude
        case baroAltitude
        case trueTrack
        case onGround
    }
}
