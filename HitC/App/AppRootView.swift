//
//  AppRootView.swift
//  HitC
//
//  Created by Matt Symons on 28/1/2026.
//

import SwiftUI

struct AppRootView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        Group {
            if !appState.isSignedIn {
                AuthView()
            } else if appState.profile == nil {
                VStack(spacing: 12) {
                    ProgressView("Loading profile…")
                    if let lastError = appState.lastError {
                        Text(lastError).foregroundStyle(.red).multilineTextAlignment(.center)
                        Button("Retry") { Task { await appState.refreshSession() } }
                        Button("Sign out") { Task { await appState.signOut() } }
                    }
                }
                .padding()
            } else if appState.profile?.is18Plus != true {
                AgeGateView()
            } else {
                MainTabView()
            }
        }
        .task { await appState.refreshSession() }
    }
}

private struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView().tabItem { Label("Home", systemImage: "house") }
            ProfileView().tabItem { Label("Profile", systemImage: "person.circle") }
            SettingsView().tabItem { Label("Settings", systemImage: "gear") }
        }
    }
}
