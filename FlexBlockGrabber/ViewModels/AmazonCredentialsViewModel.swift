//
//  AmazonCredentialsViewModel.swift
//  FlexBlockGrabber
//
//  Created by Ali Taghipourfard on 3/15/25.
//

import Foundation
import Combine

class AmazonCredentialsViewModel: ObservableObject {
    @Published var amazonEmail = ""
    @Published var amazonPassword = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    func saveCredentials(completion: @escaping (Bool) -> Void) {
        isLoading = true
        errorMessage = nil
        
        UserManager.shared.updateAmazonCredentials(email: amazonEmail, password: amazonPassword) { [weak self] success in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if success {
                    self?.successMessage = "Amazon credentials saved successfully"
                    completion(true)
                } else {
                    self?.errorMessage = "Failed to save Amazon credentials"
                    completion(false)
                }
            }
        }
    }
}
