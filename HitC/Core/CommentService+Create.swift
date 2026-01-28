//
//  CommentService+Create.swift
//  HitC
//
//  Created by Matt Symons on 28/1/2026.
//

import Foundation
import Supabase

extension CommentService {
    static func addComment(postId: UUID, body: String) async throws {
        let uid = try await SupabaseManager.client.auth.session.user.id

        try await SupabaseManager.client
            .from("comments")
            .insert([
                "post_id": postId.uuidString,
                "author_id": uid.uuidString,
                "body": body
            ])
            .execute()
    }
}
