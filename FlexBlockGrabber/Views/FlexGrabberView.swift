//
//  FlexBlockGrabberApp.swift
//  FlexBlockGrabber
//
//  Created by Ali Taghipourfard on 3/15/25.
//
#if false

import SwiftUI

@main
struct FlexGrabberView: App {
    @StateObject private var userManager = UserManager.shared
    
    var body: some Scene {
        WindowGroup {
            if userManager.isLoggedIn {
                if userManager.hasAmazonCredentials {
                    MainTabView()
                } else {
                    AmazonCredentialsView()
                }
            } else {
                LoginView()
            }
        }
    }
}
struct MyDisabledFile {
    // ...
}
#endif
