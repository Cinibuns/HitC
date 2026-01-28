//
//  AuthView.swift
//  HitC
//
//  Created by Matt Symons on 28/1/2026.
//

import SwiftUI
import Supabase

struct AuthView: View {
    @EnvironmentObject var appState: AppState

    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorText: String?

    var body: some View {
        NavigationView {
            ZStack {
                CloudBackground()

                VStack(spacing: 16) {
                    VStack(spacing: 6) {
                        Text("Head in the Clouds")
                            .font(.title2.weight(.bold))
                            .foregroundStyle(.white)

                        Text("Sign in to continue")
                            .font(.subheadline)
                            .foregroundStyle(Theme.textSecondary)
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        TextField("Email", text: $email)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                            .autocorrectionDisabled()
                            .textFieldStyle(.roundedBorder)

                        SecureField("Password", text: $password)
                            .textFieldStyle(.roundedBorder)

                        if let errorText {
                            Text(errorText)
                                .foregroundStyle(.red)
                                .font(.caption)
                        }

                        Button {
                            Task { await signIn() }
                        } label: {
                            if isLoading { ProgressView().tint(.white) }
                            else { Text("Sign in") }
                        }
                        .buttonStyle(GradientPrimaryButtonStyle())
                        .disabled(isLoading)

                        Button {
                            Task { await signUp() }
                        } label: {
                            Text("Sign up")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(SoftButtonStyle())
                        .disabled(isLoading)

                        Text("No explicit content is shown by default.")
                            .font(.caption2)
                            .foregroundStyle(Theme.textSecondary)
                            .padding(.top, 2)
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

    private func signIn() async {
        isLoading = true
        defer { isLoading = false }
        errorText = nil

        do {
            _ = try await SupabaseManager.client.auth.signIn(email: email, password: password)
            await appState.refreshSession()
        } catch {
            errorText = error.localizedDescription
            print("SIGN IN ERROR:", error)
        }
    }

    private func signUp() async {
        isLoading = true
        defer { isLoading = false }
        errorText = nil

        do {
            _ = try await SupabaseManager.client.auth.signUp(email: email, password: password)
            await appState.refreshSession()

            if !appState.isSignedIn {
                errorText = "Check your email to verify, then sign in."
            }
        } catch {
            errorText = error.localizedDescription
            print("SIGN UP ERROR:", error)
        }
    }
}
