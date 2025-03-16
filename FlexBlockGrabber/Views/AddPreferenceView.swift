//
//  AddPreferenceView.swift
//  FlexBlockGrabber
//
//  Created by Ali Taghipourfard on 3/15/25.
//

import SwiftUI
import Combine

struct AddPreferenceView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = AddPreferenceViewModel()
    let onSave: () -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Basic Info")) {
                    TextField("Preference Name", text: $viewModel.name)
                        .autocapitalization(.words)
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
                
                Section(header: Text("Preferred Locations")) {
                    if viewModel.isLoading && viewModel.availableLocations.isEmpty {
                        HStack {
                            Spacer()
                            ProgressView("Loading locations...")
                            Spacer()
                        }
                    } else if viewModel.availableLocations.isEmpty {
                        Text("No locations available")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(viewModel.availableLocations, id: \.self) { location in
                            Button(action: {
                                viewModel.toggleLocation(location)
                            }) {
                                HStack {
                                    Text(location)
                                    Spacer()
                                    if viewModel.selectedLocations.contains(location) {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                            .foregroundColor(.primary)
                        }
                    }
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
            }
            .navigationTitle("Add Preference")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        viewModel.savePreference { success in
                            if success {
                                onSave()
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
                    }
                    .disabled(viewModel.name.isEmpty ||
                              viewModel.selectedDays.isEmpty ||
                              viewModel.selectedLocations.isEmpty ||
                              viewModel.isLoading)
                }
            }
        }
    }
}
