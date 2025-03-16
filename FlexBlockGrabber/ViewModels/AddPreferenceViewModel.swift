//
//  AddPreferenceViewModel.swift
//  FlexBlockGrabber
//
//  Created by Ali Taghipourfard on 3/15/25.
//

import Foundation
import Combine

class AddPreferenceViewModel: ObservableObject {
    @Published var name = ""
    @Published var selectedDays = Set<Int>()
    @Published var minDuration: Double = 1.0
    @Published var maxDuration: Double = 4.0
    @Published var hourlyRateText = "25.00"
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var availableLocations: [String] = []
    @Published var selectedLocations = Set<String>()
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadAvailableLocations()
    }
    
    var hourlyRate: Double {
        return Double(hourlyRateText) ?? 25.0
    }
    
    func toggleDay(_ day: Int) {
        if selectedDays.contains(day) {
            selectedDays.remove(day)
        } else {
            selectedDays.insert(day)
        }
    }
    
    func toggleLocation(_ location: String) {
        if selectedLocations.contains(location) {
            selectedLocations.remove(location)
        } else {
            selectedLocations.insert(location)
        }
    }
    
    func loadAvailableLocations() {
        isLoading = true
        APIService.shared.getAvailableLocations()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] result in
                self?.isLoading = false
                switch result {
                case .failure(let error):
                    self?.errorMessage = "Failed to load locations: \(error.localizedDescription)"
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] response in
                if response.success, let locations = response.locations {
                    self?.availableLocations = locations
                } else {
                    self?.errorMessage = response.message ?? "Failed to load locations"
                }
            })
            .store(in: &cancellables)
    }
    
    func savePreference(completion: @escaping (Bool) -> Void) {
        isLoading = true
        errorMessage = nil
        
        // Create a placeholder preference for the API
        let preference = BlockPreference(
            id: UUID().uuidString, // This ID will be ignored by the API
            name: name,
            preferredDates: nil,
            preferredDaysOfWeek: Array(selectedDays),
            minDuration: minDuration,
            maxDuration: maxDuration,
            minHourlyRate: hourlyRate,
            preferredLocations: Array(selectedLocations),
            active: true
        )
        
        APIService.shared.createBlockPreference(preference: preference)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] result in
                self?.isLoading = false
                
                switch result {
                case .failure(let error):
                    self?.errorMessage = "Failed to save preference: \(error.localizedDescription)"
                    completion(false)
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] response in
                if response.success {
                    completion(true)
                } else {
                    self?.errorMessage = response.message ?? "Failed to save preference"
                    completion(false)
                }
            })
            .store(in: &cancellables)
    }
}
