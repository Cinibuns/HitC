//
//  HITCApp.swift
//  HitC
//
//  Created by Matt Symons on 28/1/2026.
//

import SwiftUI

@main
struct HITCApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environmentObject(appState)
        }
    }
}
