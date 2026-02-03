//
//  SupabaseManager.swift
//  HitC
//
//  Created by Matt Symons on 28/1/2026.
//

import Foundation
import Supabase

final class SupabaseManager {
    static let shared = SupabaseManager()

    let client: SupabaseClient

    /// Backwards-compatible access
    static var client: SupabaseClient { shared.client }

    private init() {
        let url = SupabaseConfig.url
        let anonKey = SupabaseConfig.anonKey

        guard !anonKey.isEmpty else {
            fatalError("Supabase anon key is empty")
        }

        client = SupabaseClient(
            supabaseURL: url,
            supabaseKey: anonKey
        )
    }
}
