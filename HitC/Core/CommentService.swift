//
//  CommentService.swift
//  HitC
//
//  Created by Matt Symons on 28/1/2026.
//

import Foundation
import Supabase

enum CommentService {

    // MARK: - Fetch (ALL comments for a post)

    static func fetchAllComments(postId: UUID, limit: Int = 500) async throws -> [Comment] {
        try await SupabaseManager.client
            .from("comments")
            .select("id,post_id,author_id,parent_comment_id,body,created_at")
            .eq("post_id", value: postId.uuidString)
            .order("created_at", ascending: true)
            .limit(limit)
            .execute()
            .value
    }

    // MARK: - Insert

    private struct CommentInsert: Encodable {
        let post_id: String
        let author_id: String
        let body: String
        let parent_comment_id: String? // nil for top-level, UUID string for reply
    }

    static func addTopLevelComment(postId: UUID, body: String) async throws {
        let uid = try await SupabaseManager.client.auth.session.user.id
        let row = CommentInsert(
            post_id: postId.uuidString,
            author_id: uid.uuidString,
            body: body,
            parent_comment_id: nil
        )

        try await SupabaseManager.client
            .from("comments")
            .insert(row)
            .execute()
    }

    static func addReply(postId: UUID, parentCommentId: UUID, body: String) async throws {
        let uid = try await SupabaseManager.client.auth.session.user.id
        let row = CommentInsert(
            post_id: postId.uuidString,
            author_id: uid.uuidString,
            body: body,
            parent_comment_id: parentCommentId.uuidString
        )

        try await SupabaseManager.client
            .from("comments")
            .insert(row)
            .execute()
    }
}
