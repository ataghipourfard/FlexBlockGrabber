//
//  BlockPreferencesViewModel.swift
//  FlexBlockGrabber
//
//  Created by Ali Taghipourfard on 3/15/25.
//

import Foundation
import Combine

class BlockPreferencesViewModel: ObservableObject {
    @Published var preferences: [BlockPreference] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadPreferences()
    }
    
    func loadPreferences() {
        isLoading = true
        errorMessage = nil
        
        APIService.shared.getBlockPreferences()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] result in
                self?.isLoading = false
                
                switch result {
                case .failure(let error):
                    self?.errorMessage = "Failed to load preferences: \(error.localizedDescription)"
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] response in
                if response.success, let preferences = response.preferences {
                    self?.preferences = preferences
                } else {
                    self?.errorMessage = response.message ?? "Failed to load preferences"
                }
            })
            .store(in: &cancellables)
    }
    
    func togglePreferenceActive(preference: BlockPreference) {
        var updatedPreference = preference
        updatedPreference.active = !preference.active
        
        APIService.shared.updateBlockPreference(id: preference.id, preference: updatedPreference)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] result in
                switch result {
                case .failure(let error):
                    self?.errorMessage = "Failed to update preference: \(error.localizedDescription)"
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] _ in
                self?.loadPreferences()
            })
            .store(in: &cancellables)
    }
    
    func deletePreference(preference: BlockPreference) {
        APIService.shared.deleteBlockPreference(id: preference.id)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] result in
                switch result {
                case .failure(let error):
                    self?.errorMessage = "Failed to delete preference: \(error.localizedDescription)"
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] _ in
                self?.loadPreferences()
            })
            .store(in: &cancellables)
    }
}
