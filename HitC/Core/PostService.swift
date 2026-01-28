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
            .select("id,author_id,community_id,is_nsfw,created_at")
            .order("created_at", ascending: false)
            .limit(limit)
            .execute()
            .value
    }
}
