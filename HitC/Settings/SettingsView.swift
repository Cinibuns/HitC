//
//  SettingsView.swift
//  HitC
//
//  Created by Matt Symons on 28/1/2026.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState

    @State private var nsfwEnabled = false
    @State private var blurNsfw = true

    @State private var isSaving = false
    @State private var errorText: String?

    var body: some View {
        NavigationView {
            ZStack {
                LightCloudBackground()

                ScrollView {
                    VStack(spacing: 14) {

                        VStack(alignment: .leading, spacing: 10) {
                            Text("Content")
                                .font(.headline)
                                .foregroundStyle(Theme.textPrimary)

                            Toggle("Enable adult content (NSFW)", isOn: $nsfwEnabled)
                                .tint(Color(red: 0.84, green: 0.10, blue: 0.62))
                                .disabled(appState.profile?.is18Plus != true)

                            Toggle("Blur NSFW previews", isOn: $blurNsfw)
                                .tint(Color.orange.opacity(0.85))
                                .disabled(appState.profile?.is18Plus != true || nsfwEnabled == false)

                            if appState.profile?.is18Plus != true {
                                Text("Confirm 18+ to enable these settings.")
                                    .font(.caption)
                                    .foregroundStyle(Theme.textSecondary)
                            }
                        }
                        .padding(18)
                        .background(Theme.lightCard())
                        .padding(.horizontal)

                        if let errorText {
                            Text(errorText)
                                .foregroundStyle(.red)
                                .font(.caption)
                                .padding(.horizontal)
                        }

                        VStack(spacing: 10) {
                            Button {
                                Task { await save() }
                            } label: {
                                if isSaving { ProgressView().tint(.white) } else { Text("Save") }
                            }
                            .buttonStyle(NeonRingPrimaryButtonStyle())
                            .disabled(isSaving || appState.profile?.is18Plus != true)

                            Button(role: .destructive) {
                                Task { await appState.signOut() }
                            } label: {
                                Text("Sign out")
                            }
                            .buttonStyle(SoftSecondaryButtonStyle())
                        }
                        .padding(18)
                        .background(Theme.lightCard())
                        .padding(.horizontal)

                        Spacer(minLength: 24)
                    }
                    .padding(.top, 10)
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .onAppear {
                nsfwEnabled = appState.profile?.nsfwEnabled ?? false
                blurNsfw = appState.profile?.blurNsfw ?? true
            }
        }
    }

    private func save() async {
        guard appState.profile?.is18Plus == true else { return }

        isSaving = true
        defer { isSaving = false }
        errorText = nil

        do {
            try await ProfileService.updateSettings(nsfwEnabled: nsfwEnabled, blurNsfw: blurNsfw)
            await appState.refreshSession()
        } catch {
            errorText = error.localizedDescription
        }
    }
}
