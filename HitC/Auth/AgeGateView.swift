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
            VStack(spacing: 16) {
                Text("18+ Required")
                    .font(.title2).bold()

                Text("To protect safety and comply with platform rules, you must confirm you are 18+ to access the feed.")
                    .multilineTextAlignment(.center)

                if let errorText {
                    Text(errorText).foregroundStyle(.red)
                }

                Button {
                    Task { await confirm18Plus() }
                } label: {
                    if isLoading { ProgressView() } else { Text("I’m 18+ (Continue)") }
                }
                .buttonStyle(.borderedProminent)
                .disabled(isLoading)

                Spacer()
            }
            .padding()
            .navigationTitle("Age Gate")
        }
    }

    private func confirm18Plus() async {
        isLoading = true
        defer { isLoading = false }
        errorText = nil

        do {
            try await ProfileService.setIs18PlusTrue()
            await appState.refreshSession() // re-fetch profile
        } catch {
            errorText = "Couldn’t update your account. Try again."
        }
    }
}
