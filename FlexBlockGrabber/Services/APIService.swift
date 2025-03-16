//
//  APIService.swift
//  FlexBlockGrabber
//
//  Created by Ali Taghipourfard on 3/15/25.
//

import Foundation
import Combine

struct EmptyRequest: Encodable {}

enum APIError: Error, LocalizedError {
    case invalidURL
    case networkError(Error)
    case decodingError(Error)
    case serverError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .serverError(let message):
            return message
        }
    }
}

class APIService {
    static let shared = APIService()
    
    private let baseURL = "http://localhost:3000/api"
    private var token: String?
    
    private init() {}
    
    func setToken(_ token: String) {
        self.token = token
    }
    
    func clearToken() {
        self.token = nil
    }
    
    // MARK: - Authentication
    
    func login(email: String, password: String) -> AnyPublisher<LoginResponse, APIError> {
        let endpoint = "/auth/login"
        let request = LoginRequest(email: email, password: password)
        
        return makeRequest(endpoint: endpoint, method: "POST", body: request)
    }
    
    func saveAmazonCredentials(amazonEmail: String, amazonPassword: String) -> AnyPublisher<LoginResponse, APIError> {
        let endpoint = "/auth/amazon-credentials"
        let request = AmazonCredentialsRequest(amazonEmail: amazonEmail, amazonPassword: amazonPassword)
        
        return makeRequest(endpoint: endpoint, method: "POST", body: request)
    }
    
    func amazonLogin() -> AnyPublisher<LoginResponse, APIError> {
        let endpoint = "/auth/amazon-login"
        
        return makeRequest(endpoint: endpoint, method: "POST", body: nil as EmptyRequest?)
    }
    
    // MARK: - Block Preferences
    
    func getBlockPreferences() -> AnyPublisher<PreferenceResponse, APIError> {
        let endpoint = "/blocks/preferences"
        
        return makeRequest(endpoint: endpoint, method: "GET", body: nil as EmptyRequest?)
    }
    
    func createBlockPreference(preference: BlockPreference) -> AnyPublisher<PreferenceResponse, APIError> {
        let endpoint = "/blocks/preferences"
        
        return makeRequest(endpoint: endpoint, method: "POST", body: preference)
    }
    
    func updateBlockPreference(id: String, preference: BlockPreference) -> AnyPublisher<PreferenceResponse, APIError> {
        let endpoint = "/blocks/preferences/\(id)"
        
        return makeRequest(endpoint: endpoint, method: "PATCH", body: preference)
    }
    
    func deleteBlockPreference(id: String) -> AnyPublisher<PreferenceResponse, APIError> {
        let endpoint = "/blocks/preferences/\(id)"
        
        return makeRequest(endpoint: endpoint, method: "DELETE", body: nil as EmptyRequest?)
    }
    
    // MARK: - Blocks
    
    func getAvailableBlocks() -> AnyPublisher<BlocksResponse, APIError> {
        let endpoint = "/blocks/available"
        
        return makeRequest(endpoint: endpoint, method: "GET", body: nil as EmptyRequest?)
    }
    
    func acceptBlock(id: String) -> AnyPublisher<GrabberResponse, APIError> {
        let endpoint = "/blocks/accept/\(id)"
        
        return makeRequest(endpoint: endpoint, method: "POST", body: nil as EmptyRequest?)
    }
    
    func startGrabber() -> AnyPublisher<GrabberResponse, APIError> {
        let endpoint = "/blocks/start-grabber"
        
        return makeRequest(endpoint: endpoint, method: "POST", body: nil as EmptyRequest?)
    }
    
    func stopGrabber() -> AnyPublisher<GrabberResponse, APIError> {
        let endpoint = "/blocks/stop-grabber"
        
        return makeRequest(endpoint: endpoint, method: "POST", body: nil as EmptyRequest?)
    }
    
    func getAvailableLocations() -> AnyPublisher<LocationsResponse, APIError> {
        let endpoint = "/blocks/locations"
        
        return makeRequest(endpoint: endpoint, method: "GET", body: nil as EmptyRequest?)
    }
    
    // MARK: - Helper Methods
    
    private func makeRequest<T: Decodable, U: Encodable>(
        endpoint: String,
        method: String,
        body: U? = nil
    ) -> AnyPublisher<T, APIError> {
        guard let url = URL(string: baseURL + endpoint) else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = token {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = body {
            do {
                let encoder = JSONEncoder()
                let jsonData = try encoder.encode(body)
                request.httpBody = jsonData
            } catch {
                return Fail(error: APIError.networkError(error)).eraseToAnyPublisher()
            }
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .mapError { error -> APIError in
                return .networkError(error)
            }
            .map { $0.data }
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError { error -> APIError in
                if let decodingError = error as? DecodingError {
                    print("Decoding error: \(decodingError)")
                    return .decodingError(decodingError)
                } else {
                    return .networkError(error)
                }
            }
            .eraseToAnyPublisher()
    }
}
