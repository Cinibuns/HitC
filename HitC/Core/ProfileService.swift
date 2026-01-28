//
//  ProfileService.swift
//  HitC
//
//  Created by Matt Symons on 28/1/2026.
//

import Foundation
import Supabase

enum ProfileService {
    static func fetchMyProfile() async throws -> Profile {
        let session = try await SupabaseManager.client.auth.session
        let uid = session.user.id

        let rows: [Profile] = try await SupabaseManager.client
            .from("profiles")
            .select()
            .eq("id", value: uid.uuidString)
            .limit(1)
            .execute()
            .value

        guard let profile = rows.first else {
            throw NSError(
                domain: "Profile",
                code: 404,
                userInfo: [NSLocalizedDescriptionKey: "No profile row found for user"]
            )
        }

        return profile
    }
}
