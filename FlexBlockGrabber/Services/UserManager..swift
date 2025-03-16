//
//  UserManager.swift
//  FlexBlockGrabber
//
//  Created by Ali Taghipourfard on 3/15/25.
//

import Foundation
import Combine

class UserManager: ObservableObject {
    static let shared = UserManager()
    
    @Published var user: User?
    @Published var isLoggedIn: Bool = false
    @Published var hasAmazonCredentials: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        loadUserFromStorage()
    }
    
    func login(user: User, token: String) {
        self.user = user
        self.isLoggedIn = true
        self.hasAmazonCredentials = user.amazonEmail != nil && user.amazonPassword != nil
        APIService.shared.setToken(token)
        saveUserToStorage(user: user, token: token)
    }
    
    func logout() {
        self.user = nil
        self.isLoggedIn = false
        self.hasAmazonCredentials = false
        APIService.shared.clearToken()
        UserDefaults.standard.removeObject(forKey: "user")
        UserDefaults.standard.removeObject(forKey: "token")
    }
    
    func updateAmazonCredentials(email: String, password: String, completion: @escaping (Bool) -> Void) {
        APIService.shared.saveAmazonCredentials(amazonEmail: email, amazonPassword: password)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { result in
                switch result {
                case .failure:
                    completion(false)
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] response in
                if response.success, let updatedUser = response.user {
                    self?.user = updatedUser
                    self?.hasAmazonCredentials = true
                    
                    if let userData = try? JSONEncoder().encode(updatedUser),
                       let token = self?.user?.token {
                        UserDefaults.standard.set(userData, forKey: "user")
                        UserDefaults.standard.set(token, forKey: "token")
                    }
                    
                    completion(true)
                } else {
                    completion(false)
                }
            })
            .store(in: &cancellables)
    }
    
    private func loadUserFromStorage() {
        if let userData = UserDefaults.standard.data(forKey: "user"),
           let token = UserDefaults.standard.string(forKey: "token"),
           let user = try? JSONDecoder().decode(User.self, from: userData) {
            self.user = user
            self.isLoggedIn = true
            self.hasAmazonCredentials = user.amazonEmail != nil && user.amazonPassword != nil
            APIService.shared.setToken(token)
        }
    }
    
    private func saveUserToStorage(user: User, token: String) {
        if let userData = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(userData, forKey: "user")
            UserDefaults.standard.set(token, forKey: "token")
        }
    }
}
