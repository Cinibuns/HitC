//
//  SettingsView.swift
//  HitC
//
//  Created by Matt Symons on 28/1/2026.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @State private var isSigningOut = false

    var body: some View {
        NavigationView {
            List {
                Section {
                    Button(role: .destructive) {
                        Task {
                            isSigningOut = true
                            await appState.signOut()
                            isSigningOut = false
                        }
                    } label: {
                        if isSigningOut {
                            HStack { Spacer(); ProgressView(); Spacer() }
                        } else {
                            Text("Sign out")
                        }
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}
