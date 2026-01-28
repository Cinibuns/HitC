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
            VStack(spacing: 16) {
                Text("Head in the Clouds")
                    .font(.title2).bold()

                TextField("Email", text: $email)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled()
                    .textFieldStyle(.roundedBorder)

                SecureField("Password", text: $password)
                    .textFieldStyle(.roundedBorder)

                if let errorText {
                    Text(errorText).foregroundStyle(.red)
                }

                Button {
                    Task { await signIn() }
                } label: {
                    if isLoading { ProgressView() } else { Text("Sign in") }
                }
                .buttonStyle(.borderedProminent)
                .disabled(isLoading)

                Button {
                    Task { await signUp() }
                } label: {
                    Text("Sign up")
                }
                .buttonStyle(.bordered)
                .disabled(isLoading)

                Spacer()
            }
            .padding()
            .navigationTitle("Login")
        }
    }

    private func signIn() async {
        isLoading = true
        defer { isLoading = false }
        errorText = nil

        do {
            _ = try await SupabaseManager.client.auth.signIn(email: email, password: password)
            await appState.refreshSession() // IMPORTANT: fetch session + profile
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

            // If email confirmations are enabled, you may NOT get a session immediately.
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
