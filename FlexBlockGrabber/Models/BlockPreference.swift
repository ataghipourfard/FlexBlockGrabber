//
//  BlockPreference.swift
//  FlexBlockGrabber
//
//  Created by Ali Taghipourfard on 3/15/25.
//

import Foundation

struct BlockPreference: Codable, Identifiable {
    let id: String
    let name: String
    var preferredDates: [Date]?
    var preferredDaysOfWeek: [Int]?
    var minDuration: Double
    var maxDuration: Double
    var minHourlyRate: Double
    var preferredLocations: [String]
    var active: Bool
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case preferredDates
        case preferredDaysOfWeek
        case minDuration
        case maxDuration
        case minHourlyRate
        case preferredLocations
        case active
    }
}

struct PreferenceResponse: Codable {
    let success: Bool
    let preferences: [BlockPreference]?
    let message: String?
}
