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
                CloudBackground()

                ScrollView {
                    VStack(spacing: 14) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Content")
                                .font(.headline)
                                .foregroundStyle(.white)

                            Toggle("Enable adult content (NSFW)", isOn: $nsfwEnabled)
                                .tint(Color.pink.opacity(0.8))
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
                        .padding(16)
                        .background(Theme.card())

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
                                if isSaving { ProgressView().tint(.white) }
                                else { Text("Save") }
                            }
                            .buttonStyle(GradientPrimaryButtonStyle())
                            .disabled(isSaving || appState.profile?.is18Plus != true)

                            Button(role: .destructive) {
                                Task { await appState.signOut() }
                            } label: {
                                Text("Sign out")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(SoftButtonStyle())
                        }
                        .padding(16)
                        .background(Theme.card())

                        Spacer(minLength: 20)
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                }
            }
            .navigationTitle("Settings")
            .toolbarBackground(.hidden, for: .navigationBar)
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
