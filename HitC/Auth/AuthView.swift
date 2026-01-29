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

    @State private var rememberMe = true
    @State private var showPassword = false

    @State private var isLoading = false
    @State private var errorText: String?

    private var cloudsGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 1.00, green: 0.35, blue: 0.62),
                Color(red: 0.49, green: 0.36, blue: 1.00),
                Color(red: 0.23, green: 0.67, blue: 1.00)
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    var body: some View {
        NavigationView {
            ZStack {
                LightCloudBackground()

                ScrollView {
                    VStack(spacing: 18) {

                        // Top brand
                        HStack(spacing: 10) {
                            Image(systemName: "cloud.fill")
                                .font(.title2)
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 1.00, green: 0.35, blue: 0.62),
                                            Color(red: 0.49, green: 0.36, blue: 1.00),
                                            Color(red: 0.23, green: 0.67, blue: 1.00)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )

                            Text("Head in the Clouds")
                                .font(.headline.weight(.bold))
                                .foregroundStyle(Theme.textPrimary)
                        }
                        .padding(.top, 18)

                        // Main card
                        VStack(alignment: .leading, spacing: 16) {

                            // Title (no Text "+" concat)
                            VStack(alignment: .center, spacing: 8) {
                                HStack(spacing: 0) {
                                    Text("Welcome back to ")
                                        .foregroundStyle(Theme.textPrimary)

                                    Text("Clouds")
                                        .foregroundStyle(cloudsGradient)
                                }
                                .font(.title2.weight(.bold))
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)

                                Text("Your communities are waiting ✨")
                                    .font(.subheadline)
                                    .foregroundStyle(Theme.textSecondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.bottom, 6)

                            // Email
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Email")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(Theme.textPrimary)

                                HStack(spacing: 10) {
                                    Image(systemName: "envelope")
                                        .foregroundStyle(Theme.textSecondary)

                                    TextField("you@example.com", text: $email)
                                        .textInputAutocapitalization(.never)
                                        .keyboardType(.emailAddress)
                                        .autocorrectionDisabled()
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 14)
                                .background(Color.white.opacity(0.85))
                                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                                        .stroke(Color.white.opacity(0.70), lineWidth: 1)
                                )
                            }

                            // Password + forgot
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Password")
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(Theme.textPrimary)

                                    Spacer()

                                    Button("Forgot password?") {
                                        // optional later: Supabase reset email
                                    }
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(Color(red: 0.84, green: 0.10, blue: 0.62))
                                }

                                HStack(spacing: 10) {
                                    Image(systemName: "lock")
                                        .foregroundStyle(Theme.textSecondary)

                                    Group {
                                        if showPassword {
                                            TextField("••••••••", text: $password)
                                        } else {
                                            SecureField("••••••••", text: $password)
                                        }
                                    }
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled()

                                    Spacer()

                                    Button {
                                        showPassword.toggle()
                                    } label: {
                                        Image(systemName: showPassword ? "eye.slash" : "eye")
                                            .foregroundStyle(Theme.textSecondary)
                                    }
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 14)
                                .background(Color.white.opacity(0.85))
                                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                                        .stroke(Color.white.opacity(0.70), lineWidth: 1)
                                )
                            }

                            // Remember me
                            Toggle("Remember me", isOn: $rememberMe)
                                .tint(Color(red: 0.84, green: 0.10, blue: 0.62))
                                .foregroundStyle(Theme.textPrimary)
                                .padding(.top, 2)

                            if let errorText {
                                Text(errorText)
                                    .font(.caption)
                                    .foregroundStyle(.red)
                            }

                            // Primary CTA (neon ring)
                            Button {
                                Task { await signIn() }
                            } label: {
                                HStack(spacing: 10) {
                                    Text(isLoading ? "Signing in…" : "Log In")
                                    Image(systemName: "arrow.right")
                                }
                            }
                            .buttonStyle(NeonRingPrimaryButtonStyle())
                            .disabled(isLoading)

                            // “Don’t have…” line
                            HStack(spacing: 6) {
                                Text("Don’t have an account?")
                                    .font(.footnote)
                                    .foregroundStyle(Theme.textSecondary)

                                Button("Sign up") {
                                    Task { await signUp() }
                                }
                                .font(.footnote.weight(.bold))
                                .foregroundStyle(Color(red: 0.84, green: 0.10, blue: 0.62))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 4)

                            // Pride dots
                            RainbowDotsView()
                                .frame(maxWidth: .infinity)
                                .padding(.top, 4)
                        }
                        .padding(20)
                        .background(Theme.lightCard())
                        .padding(.horizontal)
                        .padding(.top, 6)

                        Text("Built with comfort-first defaults and privacy in mind.")
                            .font(.caption)
                            .foregroundStyle(Theme.textSecondary)
                            .padding(.top, 4)

                        Spacer(minLength: 30)
                    }
                }
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
        }
    }
}
