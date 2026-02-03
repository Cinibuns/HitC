//
//  AppState.swift
//  HitC
//
//  Created by Matt Symons on 28/1/2026.
//

import SwiftUI
import Combine
import Supabase

@MainActor
final class AppState: ObservableObject {
    @Published var isSignedIn: Bool = false
    @Published var profile: Profile?
    @Published var lastError: String?

    private var authListenerTask: Task<Void, Never>?

    init() {
        startAuthListener()
    }

    deinit {
        authListenerTask?.cancel()
    }

    private func startAuthListener() {
        authListenerTask?.cancel()

        authListenerTask = Task { [weak self] in
            guard let self else { return }

            // Supabase Swift emits auth events whenever session changes.
            for await state in SupabaseManager.client.auth.authStateChanges {
                switch state.event {
                case .initialSession:
                    // Fires once on launch with whatever is stored locally (or nil)
                    if state.session != nil {
                        self.isSignedIn = true
                        await self.loadProfile()
                    } else {
                        self.isSignedIn = false
                        self.profile = nil
                    }

                case .signedIn:
                    self.isSignedIn = true
                    await self.loadProfile()

                case .signedOut:
                    self.isSignedIn = false
                    self.profile = nil
                    self.lastError = nil

                case .tokenRefreshed:
                    self.isSignedIn = (state.session != nil)
                    if self.isSignedIn {
                        await self.loadProfile()
                    }

                default:
                    // other events (passwordRecovery, userUpdated, etc.)
                    break
                }
            }
        }
    }

    func refreshSession() async {
        lastError = nil

        // This makes sure we sync with whatever session exists *right now*
        do {
            let session = try await SupabaseManager.client.auth.session
            isSignedIn = true

            // If we have a session, fetch profile
            if session.user.id != UUID() {
                await loadProfile()
            }
        } catch {
            isSignedIn = false
            profile = nil
            lastError = error.localizedDescription
            print("SESSION ERROR:", error)
        }
    }

    private func loadProfile() async {
        do {
            profile = try await ProfileService.fetchMyProfile()
            lastError = nil
        } catch {
            profile = nil
            lastError = error.localizedDescription
            print("PROFILE FETCH ERROR:", error)
        }
    }

    func signOut() async {
        do { try await SupabaseManager.client.auth.signOut() } catch { }
        isSignedIn = false
        profile = nil
        lastError = nil
    }
}

