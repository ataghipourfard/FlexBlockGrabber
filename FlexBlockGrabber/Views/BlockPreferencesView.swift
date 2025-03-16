//
//  BlockPreferencesView.swift
//  FlexBlockGrabber
//
//  Created by Ali Taghipourfard on 3/15/25.
//

import SwiftUI
import Combine

struct BlockPreferencesView: View {
    @StateObject private var viewModel = BlockPreferencesViewModel()
    @State private var showingAddPreference = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isLoading && viewModel.preferences.isEmpty {
                    ProgressView("Loading preferences...")
                } else if viewModel.preferences.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "slider.horizontal.3")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.gray)
                        
                        Text("No preferences yet")
                            .font(.headline)
                        
                        Text("Create your first block preference to start grabbing blocks")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        
                        Button("Add Preference") {
                            showingAddPreference = true
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    .padding()
                } else {
                    List {
                        ForEach(viewModel.preferences) { preference in
                            PreferenceRow(preference: preference, viewModel: viewModel)
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                viewModel.deletePreference(preference: viewModel.preferences[index])
                            }
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                    .refreshable {
                        viewModel.loadPreferences()
                    }
                }
                
                if let errorMessage = viewModel.errorMessage {
                    VStack {
                        Spacer()
                        
                        Text(errorMessage)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .padding()
                        
                        Spacer().frame(height: 50)
                    }
                }
            }
            .navigationTitle("Block Preferences")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if presentationMode.wrappedValue.isPresented {
                        Button("Done") {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddPreference = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddPreference) {
                AddPreferenceView(onSave: {
                    viewModel.loadPreferences()
                })
            }
        }
    }
}

struct PreferenceRow: View {
    let preference: BlockPreference
    let viewModel: BlockPreferencesViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(preference.name)
                    .font(.headline)
                
                Spacer()
                
                Toggle("", isOn: Binding(
                    get: { preference.active },
                    set: { _ in viewModel.togglePreferenceActive(preference: preference) }
                ))
                .labelsHidden()
            }
            
            Group {
                if let days = preference.preferredDaysOfWeek, !days.isEmpty {
                    Text("Days: \(formatDays(days))")
                        .font(.caption)
                }
                
                // Display preferred dates in US format if available
                if let dates = preference.preferredDates, !dates.isEmpty {
                    Text("Dates: \(formatDates(dates))")
                        .font(.caption)
                }
                
                Text("Duration: \(preference.minDuration) - \(preference.maxDuration) hours")
                    .font(.caption)
                
                Text("Min Rate: $\(String(format: "%.2f", preference.minHourlyRate))/hr")
                    .font(.caption)
                
                Text("Locations: \(preference.preferredLocations.joined(separator: ", "))")
                    .font(.caption)
                    .lineLimit(1)
            }
            .foregroundColor(.secondary)
        }
        .padding(.vertical, 5)
    }
    
    private func formatDays(_ days: [Int]) -> String {
        let dayNames = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        return days.map { dayNames[$0] }.joined(separator: ", ")
    }
    
    private func formatDates(_ dates: [Date]) -> String {
        return dates.map { $0.usDateString }.joined(separator: ", ")
    }
}
