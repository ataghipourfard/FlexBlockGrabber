//
//  LoginView.swift
//  FlexBlockGrabber
//
//  Created by Ali Taghipourfard on 3/15/25.
//

import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    
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
                            .frame(width: 80, height: 80)
                            .foregroundColor(Color.blue)
                        
                        Text("Amazon Flex Block Grabber")
                            .font(.title)
                            .fontWeight(.bold)
                    }
                    .padding(.top, 50)
                    
                    // Login form
                    VStack(spacing: 20) {
                        TextField("Email", text: $viewModel.email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .disableAutocorrection(true)
                        
                        SecureField("Password", text: $viewModel.password)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                        
                        if let errorMessage = viewModel.errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                        
                        Button(action: {
                            viewModel.login { _ in
                                // Navigation handled by app view
                            }
                        }) {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Login")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .disabled(viewModel.isLoading)
                    }
                    .padding(.horizontal, 40)
                    
                    Spacer()
                }
            }
            .navigationBarHidden(true)
        }
    }
}
