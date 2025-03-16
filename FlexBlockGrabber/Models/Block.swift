//
//  Block.swift
//  FlexBlockGrabber
//
//  Created by Ali Taghipourfard on 3/15/25.
//

import Foundation

struct Block: Codable, Identifiable {
    let id: String
    let date: String
    let timeRange: String
    let rate: String
    let duration: String
    let location: String
    
    var durationHours: Double {
        return Double(duration.replacingOccurrences(of: "h", with: "")) ?? 0
    }
    
    var payAmount: Double {
        return Double(rate.replacingOccurrences(of: "$", with: "")) ?? 0
    }
}

struct BlocksResponse: Codable {
    let success: Bool
    let blocks: [Block]?
    let message: String?
}

struct GrabberResponse: Codable {
    let success: Bool
    let message: String?
}

struct LocationsResponse: Codable {
    let success: Bool
    let locations: [String]?
    let message: String?
}
