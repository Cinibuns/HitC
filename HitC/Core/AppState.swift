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

    func refreshSession() async {
        lastError = nil

        do {
            _ = try await SupabaseManager.client.auth.session
            isSignedIn = true
        } catch {
            isSignedIn = false
            profile = nil
            lastError = error.localizedDescription
            print("SESSION ERROR:", error)
            return
        }

        do {
            profile = try await ProfileService.fetchMyProfile()
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
