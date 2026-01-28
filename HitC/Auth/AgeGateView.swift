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
                CloudBackground()

                VStack(spacing: 16) {
                    VStack(spacing: 6) {
                        Text("18+ Required")
                            .font(.title2.weight(.bold))
                            .foregroundStyle(.white)

                        Text("Confirm you’re 18+ to access the feed and settings.")
                            .font(.subheadline)
                            .foregroundStyle(Theme.textSecondary)
                            .multilineTextAlignment(.center)
                    }

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
                            if isLoading { ProgressView().tint(.white) }
                            else { Text("I’m 18+ (Continue)") }
                        }
                        .buttonStyle(GradientPrimaryButtonStyle())
                        .disabled(isLoading)

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
                    .padding(.horizontal)

                    Spacer()
                }
                .padding(.top, 24)
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
