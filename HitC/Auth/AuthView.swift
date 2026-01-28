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
                    Text("Create account")
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
            appState.setSignedIn(true)
        } catch {
            errorText = "Sign in failed."
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
            errorText = "Sign up failed."
        }
    }
}
