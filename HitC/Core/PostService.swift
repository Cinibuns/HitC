//
//  PostService.swift
//  HitC
//
//  Created by Matt Symons on 28/1/2026.
//

import Foundation
import Supabase

enum PostService {
    static func fetchFeed(limit: Int = 25) async throws -> [Post] {
        try await SupabaseManager.client
            .from("posts")
            .select("id,author_id,community_id,is_nsfw,comment_count,created_at,image_url")
            .order("created_at", ascending: false)
            .limit(limit)
            .execute()
            .value
    }

    static func fetchPost(id: UUID) async throws -> Post {
        let rows: [Post] = try await SupabaseManager.client
            .from("posts")
            .select("id,author_id,community_id,is_nsfw,comment_count,created_at,image_url")
            .eq("id", value: id.uuidString)
            .limit(1)
            .execute()
            .value

        guard let post = rows.first else {
            throw NSError(
                domain: "Post",
                code: 404,
                userInfo: [NSLocalizedDescriptionKey: "Post not found"]
            )
        }

        return post
    }
}
