//
//  HomeViewModel.swift
//  FlexBlockGrabber
//
//  Created by Ali Taghipourfard on 3/15/25.
//

import Foundation
import Combine

class HomeViewModel: ObservableObject {
    @Published var isGrabbing = false
    @Published var statusMessage = "Grabber is idle"
    @Published var blocks: [Block] = []
    @Published var errorMessage: String?
    @Published var isLoading = false
    @Published var successMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    func startGrabbing() {
        isLoading = true
        errorMessage = nil
        
        APIService.shared.startGrabber()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] result in
                self?.isLoading = false
                
                switch result {
                case .failure(let error):
                    self?.errorMessage = "Failed to start grabber: \(error.localizedDescription)"
                    self?.isGrabbing = false
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] response in
                if response.success {
                    self?.isGrabbing = true
                    self?.statusMessage = "Grabber is actively looking for blocks"
                    self?.successMessage = "Block grabber started successfully!"
                } else {
                    self?.errorMessage = response.message ?? "Failed to start grabber"
                    self?.isGrabbing = false
                }
            })
            .store(in: &cancellables)
    }
    
    func stopGrabbing() {
        isLoading = true
        errorMessage = nil
        
        APIService.shared.stopGrabber()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] result in
                self?.isLoading = false
                
                switch result {
                case .failure(let error):
                    self?.errorMessage = "Failed to stop grabber: \(error.localizedDescription)"
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] response in
                if response.success {
                    self?.isGrabbing = false
                    self?.statusMessage = "Grabber is idle"
                    self?.successMessage = "Block grabber stopped"
                } else {
                    self?.errorMessage = response.message ?? "Failed to stop grabber"
                }
            })
            .store(in: &cancellables)
    }
    
    func checkBlocks() {
        isLoading = true
        errorMessage = nil
        
        APIService.shared.getAvailableBlocks()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] result in
                self?.isLoading = false
                
                switch result {
                case .failure(let error):
                    self?.errorMessage = "Failed to get blocks: \(error.localizedDescription)"
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] response in
                if response.success, let blocks = response.blocks {
                    self?.blocks = blocks
                    if blocks.isEmpty {
                        self?.successMessage = "No blocks available at this time"
                    } else {
                        self?.successMessage = "Found \(blocks.count) available blocks"
                    }
                } else {
                    self?.errorMessage = response.message ?? "Failed to get blocks"
                }
            })
            .store(in: &cancellables)
    }
}
