//
//  LoginViewModel.swift
//  FlexBlockGrabber
//
//  Created by Ali Taghipourfard on 3/15/25.
//

import Foundation
import Combine

class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    func login(completion: @escaping (Bool) -> Void) {
        isLoading = true
        errorMessage = nil
        
        APIService.shared.login(email: email, password: password)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] result in
                self?.isLoading = false
                
                switch result {
                case .failure(let error):
                    switch error {
                    case .serverError(let message):
                        self?.errorMessage = message
                    default:
                        self?.errorMessage = "Login failed. Please try again."
                    }
                    completion(false)
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] response in
                if response.success, let token = response.token, let user = response.user {
                    UserManager.shared.login(user: user, token: token)
                    completion(true)
                } else {
                    self?.errorMessage = response.message ?? "Login failed. Please try again."
                    completion(false)
                }
            })
            .store(in: &cancellables)
    }
}
