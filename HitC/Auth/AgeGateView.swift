//
//  AgeGateView.swift
//  HitC
//
//  Created by Matt Symons on 28/1/2026.
//

import SwiftUI

struct AgeGateView: View {
    @EnvironmentObject var appState: AppState
    @State private var isLoading = false
    @State private var errorText: String?

    var body: some View {
        NavigationView {
            ZStack {
                LightCloudBackground()

                VStack(spacing: 16) {
                    VStack(spacing: 8) {
                        Text("18+ Required")
                            .font(.title2.weight(.bold))
                            .foregroundStyle(Theme.textPrimary)

                        Text("Confirm you’re 18+ to access the feed and settings.")
                            .font(.subheadline)
                            .foregroundStyle(Theme.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 24)

                    VStack(spacing: 12) {
                        if let errorText {
                            Text(errorText)
                                .foregroundStyle(.red)
                                .font(.caption)
                                .multilineTextAlignment(.center)
                        }

                        Button {
                            Task { await confirm18Plus() }
                        } label: {
                            if isLoading {
                                ProgressView().tint(.white)
                            } else {
                                Text("I’m 18+ (Continue)")
                            }
                        }
                        .buttonStyle(NeonRingPrimaryButtonStyle())
                        .disabled(isLoading)

                        Button(role: .destructive) {
                            Task { await appState.signOut() }
                        } label: {
                            Text("Sign out")
                        }
                        .buttonStyle(SoftSecondaryButtonStyle())
                        .disabled(isLoading)
                    }
                    .padding(18)
                    .background(Theme.lightCard())
                    .padding(.horizontal)

                    Spacer()
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
        }
    }

    private func confirm18Plus() async {
        isLoading = true
        defer { isLoading = false }
        errorText = nil

        do {
            try await ProfileService.setIs18PlusTrue()
            await appState.refreshSession()
        } catch {
            errorText = error.localizedDescription
        }
    }
}
