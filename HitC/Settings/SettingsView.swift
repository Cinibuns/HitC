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
            List {
                if let profile = appState.profile {
                    Section("Content") {
                        Toggle("Enable adult content (NSFW)", isOn: $nsfwEnabled)
                            .disabled(profile.is18Plus != true)

                        Toggle("Blur NSFW previews", isOn: $blurNsfw)
                            .disabled(profile.is18Plus != true || nsfwEnabled == false)

                        if profile.is18Plus != true {
                            Text("Confirm 18+ to enable these settings.")
                                .font(.footnote)
                        }
                    }

                    if let errorText {
                        Section {
                            Text(errorText).foregroundStyle(.red)
                        }
                    }

                    Section {
                        Button {
                            Task { await save() }
                        } label: {
                            if isSaving {
                                HStack { Spacer(); ProgressView(); Spacer() }
                            } else {
                                Text("Save")
                            }
                        }
                        .disabled(isSaving || profile.is18Plus != true)

                        Button(role: .destructive) {
                            Task { await appState.signOut() }
                        } label: {
                            Text("Sign out")
                        }
                    }
                } else {
                    Section {
                        ProgressView("Loading…")
                    }
                }
            }
            .navigationTitle("Settings")
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
            await appState.refreshSession() // re-fetch profile
        } catch {
            errorText = error.localizedDescription
        }
    }
}
