//
//  PublicProfileService.swift
//  HitC
//
//  Created by Matt Symons on 28/1/2026.
//

import Foundation
import Supabase

enum PublicProfileService {
    static func fetchProfiles(ids: [UUID]) async throws -> [PublicProfile] {
        let unique = Array(Set(ids))
        guard !unique.isEmpty else { return [] }

        let idStrings = unique.map { $0.uuidString }

        return try await SupabaseManager.client
            .from("public_profiles")
            .select("id,username,display_name,avatar_url")
            .in("id", values: idStrings)
            .execute()
            .value
    }
}
