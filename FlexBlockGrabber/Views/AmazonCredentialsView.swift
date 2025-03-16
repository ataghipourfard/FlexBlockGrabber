//
//  AmazonCredentialsView.swift
//  FlexBlockGrabber
//
//  Created by Ali Taghipourfard on 3/15/25.
//

import SwiftUI

struct AmazonCredentialsView: View {
    @StateObject private var viewModel = AmazonCredentialsViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemBackground).edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 30) {
                    // Logo and title
                    VStack(spacing: 10) {
                        Image(systemName: "cube.box.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .foregroundColor(Color.blue)
                        
                        Text("Connect to Amazon Flex")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Please enter your Amazon Flex credentials to allow the app to grab blocks on your behalf")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top, 40)
                    
                    // Credentials form
                    VStack(spacing: 20) {
                        TextField("Amazon Flex Email", text: $viewModel.amazonEmail)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .disableAutocorrection(true)
                        
                        SecureField("Amazon Flex Password", text: $viewModel.amazonPassword)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                        
                        if let errorMessage = viewModel.errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                        
                        if let successMessage = viewModel.successMessage {
                            Text(successMessage)
                                .foregroundColor(.green)
                                .font(.caption)
                        }
                        
                        Button(action: {
                            viewModel.saveCredentials { _ in
                                // Navigation handled by app view
                            }
                        }) {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Connect Account")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .disabled(viewModel.isLoading)
                        
                        Button(action: {
                            UserManager.shared.logout()
                        }) {
                            Text("Logout")
                                .foregroundColor(.red)
                        }
                        .padding(.top, 20)
                    }
                    .padding(.horizontal, 40)
                    
                    Spacer()
                }
            }
            .navigationBarHidden(true)
        }
    }
}
