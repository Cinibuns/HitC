//
//  ProfileView.swift
//  HitC
//
//  Created by Matt Symons on 28/1/2026.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Signed in: \(appState.isSignedIn ? "Yes" : "No")")
                Text("User ID: \(appState.profile?.id.uuidString ?? "-")")
                Text("18+: \(appState.profile?.is18Plus == true ? "Yes" : "No")")
                Text("NSFW enabled: \(appState.profile?.nsfwEnabled == true ? "Yes" : "No")")
                Text("Blur NSFW: \(appState.profile?.blurNsfw == true ? "Yes" : "No")")
                Spacer()
            }
            .padding()
            .navigationTitle("Profile")
        }
    }
}
