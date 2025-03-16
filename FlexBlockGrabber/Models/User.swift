//
//  User.swift
//  FlexBlockGrabber
//
//  Created by Ali Taghipourfard on 3/15/25.
//

import Foundation

struct User: Codable, Identifiable {
    let id: String
    let name: String
    let email: String
    var amazonEmail: String?
    var amazonPassword: String?
    var token: String?
    var deviceToken: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case email
        case amazonEmail
        case amazonPassword
        case token
        case deviceToken
    }
}

struct LoginRequest: Codable {
    let email: String
    let password: String
}

struct AmazonCredentialsRequest: Codable {
    let amazonEmail: String
    let amazonPassword: String
}

struct LoginResponse: Codable {
    let success: Bool
    let user: User?
    let token: String?
    let message: String?
}
