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

    func refreshSession() async {
        do {
            _ = try await SupabaseManager.client.auth.session
            isSignedIn = true
        } catch {
            isSignedIn = false
        }
    }

    func setSignedIn(_ value: Bool) {
        isSignedIn = value
    }

    func signOut() async {
        do { try await SupabaseManager.client.auth.signOut() } catch { }
        isSignedIn = false
    }
}
