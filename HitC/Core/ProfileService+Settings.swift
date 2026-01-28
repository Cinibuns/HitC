//
//  ProfileService+Settings.swift
//  HitC
//
//  Created by Matt Symons on 28/1/2026.
//

import Foundation
import Supabase

extension ProfileService {
    static func updateSettings(nsfwEnabled: Bool, blurNsfw: Bool) async throws {
        let uid = try await SupabaseManager.client.auth.session.user.id

        try await SupabaseManager.client
            .from("profiles")
            .update([
                "nsfw_enabled": nsfwEnabled,
                "blur_nsfw": blurNsfw
            ])
            .eq("id", value: uid.uuidString)
            .execute()
    }
}
