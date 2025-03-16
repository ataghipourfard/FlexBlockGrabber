//
//  FlexBlockGrabberApp.swift
//  FlexBlockGrabber
//
//  Created by Ali Taghipourfard on 3/15/25.
//

//
//  FlexBlockGrabberApp.swift
//  FlexBlockGrabber
//
//  Created by Ali Taghipourfard on 3/15/25.
//

import SwiftUI

@main
struct FlexBlockGrabberApp: App {
    @StateObject private var userManager = UserManager.shared
    
    var body: some Scene {
        WindowGroup {
            if userManager.isLoggedIn {
                if userManager.hasAmazonCredentials {
                    MainTabView() // Use MainTabView instead of HomeView
                } else {
                    AmazonCredentialsView()
                }
            } else {
                LoginView()
            }
        }
    }
}
