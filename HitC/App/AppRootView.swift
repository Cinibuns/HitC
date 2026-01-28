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
            if appState.isSignedIn {
                MainTabView()
            } else {
                AuthView()
            }
        }
        .task {
            await appState.refreshSession()
        }
    }
}

private struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("Home", systemImage: "house") }

            ProfileView()
                .tabItem { Label("Profile", systemImage: "person.circle") }

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gear") }
        }
    }
}
