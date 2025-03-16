//
//  SettingsView.swift
//  FlexBlockGrabber
//
//  Created by Ali Taghipourfard on 3/15/25.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject private var userManager = UserManager.shared
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Account")) {
                    HStack {
                        Text("Email")
                        Spacer()
                        Text(userManager.user?.email ?? "")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Amazon Email")
                        Spacer()
                        Text(userManager.user?.amazonEmail ?? "")
                            .foregroundColor(.secondary)
                    }
                    
                    Button("Logout") {
                        userManager.logout()
                    }
                    .foregroundColor(.red)
                }
                
                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Settings")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
