//
//  ProfileService+Update.swift
//  HitC
//
//  Created by Matt Symons on 28/1/2026.
//

import Foundation
import Supabase

extension ProfileService {
    static func setIs18PlusTrue() async throws {
        let uid = try await SupabaseManager.client.auth.session.user.id

        try await SupabaseManager.client
            .from("profiles")
            .update(["is_18_plus": true])
            .eq("id", value: uid.uuidString)
            .execute()
    }
}
