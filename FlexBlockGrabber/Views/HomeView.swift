//
//  HomeView.swift
//  FlexBlockGrabber
//
//  Created by Ali Taghipourfard on 3/15/25.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var showingAddPreference = false
    @State private var showingPreferences = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Status card
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Block Grabber Status")
                            .font(.headline)
                        
                        HStack {
                            VStack(alignment: .leading, spacing: 5) {
                                Text(viewModel.isGrabbing ? "Active" : "Idle")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(viewModel.isGrabbing ? .green : .gray)
                                
                                Text(viewModel.statusMessage)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                if viewModel.isGrabbing {
                                    viewModel.stopGrabbing()
                                } else {
                                    viewModel.startGrabbing()
                                }
                            }) {
                                Text(viewModel.isGrabbing ? "Stop" : "Start")
                                    .fontWeight(.semibold)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 10)
                                    .background(viewModel.isGrabbing ? Color.red : Color.green)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                            .disabled(viewModel.isLoading)
                        }
                        
                        if let errorMessage = viewModel.errorMessage {
                            Text(errorMessage)
                                .font(.caption)
                                .foregroundColor(.red)
                                .padding(.top, 5)
                        }
                        
                        if let successMessage = viewModel.successMessage {
                            Text(successMessage)
                                .font(.caption)
                                .foregroundColor(.green)
                                .padding(.top, 5)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Quick actions
                    HStack(spacing: 12) {
                        Button(action: {
                            showingAddPreference = true
                        }) {
                            VStack {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 24))
                                Text("Add Preference")
                                    .font(.caption)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(8)
                        }
                        
                        Button(action: {
                            showingPreferences = true
                        }) {
                            VStack {
                                Image(systemName: "slider.horizontal.3")
                                    .font(.system(size: 24))
                                Text("Preferences")
                                    .font(.caption)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.purple.opacity(0.1))
                            .foregroundColor(.purple)
                            .cornerRadius(8)
                        }
                        
                        Button(action: {
                            viewModel.checkBlocks()
                        }) {
                            VStack {
                                Image(systemName: "arrow.clockwise")
                                    .font(.system(size: 24))
                                Text("Check Blocks")
                                    .font(.caption)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange.opacity(0.1))
                            .foregroundColor(.orange)
                            .cornerRadius(8)
                        }
                    }
                    
                    // Available blocks list
                    if !viewModel.blocks.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Available Blocks")
                                .font(.headline)
                            
                            ForEach(viewModel.blocks) { block in
                                BlockRow(block: block)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                }
                .padding()
            }
            .navigationTitle("Amazon Flex Grabber")
            .sheet(isPresented: $showingAddPreference) {
                AddPreferenceView(onSave: {
                    viewModel.successMessage = "Preference saved successfully"
                })
            }
            .sheet(isPresented: $showingPreferences) {
                BlockPreferencesView()
            }
            .onAppear {
                viewModel.checkBlocks()
            }
        }
    }
}

struct BlockRow: View {
    let block: Block
    
    // In HomeView.swift, replace the date formatting code in BlockRow with:

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text(block.location)
                    .font(.headline)
                
                formattedDateTimeView
                
                Text("Duration: \(block.duration)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(block.rate)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.green)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }

    // Add this computed property to the BlockRow struct:
    private var formattedDateTimeView: some View {
        // Compute values outside the view builder closure
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let parsedDate = dateFormatter.date(from: block.date)
        
        return Group {
            if let date = parsedDate {
                Text("\(date.usDateString) - \(block.timeRange)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else {
                Text("\(block.date) - \(block.timeRange)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }

}

