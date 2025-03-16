//
//  EditPreferenceView.swift
//  FlexBlockGrabber
//
//  Created by Ali Taghipourfard on 3/15/25.
//

import SwiftUI
import Combine

struct EditPreferenceView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel: EditPreferenceViewModel
    let onSave: () -> Void
    
    init(preference: BlockPreference, onSave: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: EditPreferenceViewModel(preference: preference))
        self.onSave = onSave
    }
    
    var body: some View {
        Form {
            Section(header: Text("Basic Info")) {
                TextField("Preference Name", text: $viewModel.name)
            }
            
            Section(header: Text("Days of Week")) {
                ForEach(0..<7) { index in
                    let day = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"][index]
                    
                    Button(action: {
                        viewModel.toggleDay(index)
                    }) {
                        HStack {
                            Text(day)
                            Spacer()
                            if viewModel.selectedDays.contains(index) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .foregroundColor(.primary)
                }
            }
            
            Section(header: Text("Block Duration (hours)")) {
                HStack {
                    Text("Min: \(viewModel.minDuration, specifier: "%.1f")")
                    Slider(value: $viewModel.minDuration, in: 1...6, step: 0.5)
                }
                
                HStack {
                    Text("Max: \(viewModel.maxDuration, specifier: "%.1f")")
                    Slider(value: $viewModel.maxDuration, in: viewModel.minDuration...6, step: 0.5)
                }
            }
            
            Section(header: Text("Minimum Hourly Rate")) {
                HStack {
                    Text("$")
                    TextField("25.00", text: $viewModel.hourlyRateText)
                        .keyboardType(.decimalPad)
                }
            }
            
            Section {
                Toggle("Active", isOn: $viewModel.isActive)
            }
            
            if viewModel.isLoading {
                Section {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                }
            }
            
            if let errorMessage = viewModel.errorMessage {
                Section {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
            }
            
            Section {
                Button("Delete Preference") {
                    viewModel.deletePreference { success in
                        if success {
                            onSave()
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
                .foregroundColor(.red)
            }
        }
        .navigationTitle("Edit Preference")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    viewModel.updatePreference { success in
                        if success {
                            onSave()
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
                .disabled(viewModel.name.isEmpty || viewModel.selectedDays.isEmpty || viewModel.isLoading)
            }
        }
    }
}

class EditPreferenceViewModel: ObservableObject {
    @Published var name: String
    @Published var selectedDays: Set<Int>
    @Published var minDuration: Double
    @Published var maxDuration: Double
    @Published var hourlyRateText: String
    @Published var isActive: Bool
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedLocations: Set<String> = []

    
    private let preferenceId: String
    private var cancellables = Set<AnyCancellable>()
    
    init(preference: BlockPreference) {
        self.preferenceId = preference.id
        self.name = preference.name
        self.selectedDays = Set(preference.preferredDaysOfWeek ?? [])
        self.minDuration = preference.minDuration
        self.maxDuration = preference.maxDuration
        self.hourlyRateText = String(format: "%.2f", preference.minHourlyRate)
        self.isActive = preference.active
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
    
    func updatePreference(completion: @escaping (Bool) -> Void) {
        isLoading = true
        errorMessage = nil
        
        let preference = BlockPreference(
            id: preferenceId,
            name: name,
            preferredDates: nil,
            preferredDaysOfWeek: Array(selectedDays),
            minDuration: minDuration,
            maxDuration: maxDuration,
            minHourlyRate: hourlyRate,
            preferredLocations: Array(selectedLocations), // Add this line
            active: isActive
        )
        
        APIService.shared.updateBlockPreference(id: preferenceId, preference: preference)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] result in
                self?.isLoading = false
                
                switch result {
                case .failure(let error):
                    self?.errorMessage = "Failed to update preference: \(error.localizedDescription)"
                    completion(false)
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] response in
                if response.success {
                    completion(true)
                } else {
                    self?.errorMessage = response.message ?? "Failed to update preference"
                    completion(false)
                }
            })
            .store(in: &cancellables)
    }
    
    func deletePreference(completion: @escaping (Bool) -> Void) {
        isLoading = true
        errorMessage = nil
        
        APIService.shared.deleteBlockPreference(id: preferenceId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] result in
                self?.isLoading = false
                
                switch result {
                case .failure(let error):
                    self?.errorMessage = "Failed to delete preference: \(error.localizedDescription)"
                    completion(false)
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] response in
                if response.success {
                    completion(true)
                } else {
                    self?.errorMessage = response.message ?? "Failed to delete preference"
                    completion(false)
                }
            })
            .store(in: &cancellables)
    }
}
