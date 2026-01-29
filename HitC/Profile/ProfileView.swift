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
            ZStack {
                LightCloudBackground()

                VStack(spacing: 14) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Your Profile")
                            .font(.headline)
                            .foregroundStyle(Theme.textPrimary)

                        if let p = appState.profile {
                            InfoRow(label: "User ID", value: p.id.uuidString.prefix(8) + "…")
                            InfoRow(label: "18+", value: p.is18Plus ? "Yes" : "No")
                            InfoRow(label: "NSFW enabled", value: p.nsfwEnabled ? "Yes" : "No")
                            InfoRow(label: "Blur NSFW", value: p.blurNsfw ? "Yes" : "No")
                        } else {
                            Text("Loading…")
                                .foregroundStyle(Theme.textSecondary)
                        }
                    }
                    .padding(18)
                    .background(Theme.lightCard())
                    .padding(.horizontal)

                    Spacer()
                }
                .padding(.top, 10)
            }
            .navigationTitle("")
            .navigationBarHidden(true)
        }
    }
}

private struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.textPrimary)
            Spacer()
            Text(value)
                .font(.caption)
                .foregroundStyle(Theme.textSecondary)
        }
        .padding(.vertical, 6)
    }
}
