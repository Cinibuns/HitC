//
//  LikeService.swift
//  HitC
//
//  Created by Matt Symons on 28/1/2026.
//

import Foundation
import Supabase

enum LikeService {
    static func hasLiked(postId: UUID) async throws -> Bool {
        let uid = try await SupabaseManager.client.auth.session.user.id

        let rows: [PostLike] = try await SupabaseManager.client
            .from("post_likes")
            .select("post_id,user_id")
            .eq("post_id", value: postId.uuidString)
            .eq("user_id", value: uid.uuidString)
            .limit(1)
            .execute()
            .value

        return !rows.isEmpty
    }
}
extension LikeService {
    static func toggleLike(postId: UUID, liked: Bool) async throws {
        let uid = try await SupabaseManager.client.auth.session.user.id

        if liked {
            try await SupabaseManager.client
                .from("post_likes")
                .delete()
                .eq("post_id", value: postId.uuidString)
                .eq("user_id", value: uid.uuidString)
                .execute()
        } else {
            try await SupabaseManager.client
                .from("post_likes")
                .insert([
                    "post_id": postId.uuidString,
                    "user_id": uid.uuidString
                ])
                .execute()
        }
    }
}
