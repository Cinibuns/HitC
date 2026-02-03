//
//  CommunitiesService.swift
//  HitC
//
//  Created by Matt Symons on 3/2/2026.
//

import Foundation
import Supabase

final class CommunitiesService {
    private var client: SupabaseClient { SupabaseManager.shared.client }

    func fetchCommunities(limit: Int = 50) async throws -> [Community] {
        try await client
            .from("communities")
            .select("id,name,slug,description,is_private,is_nsfw,owner_id,member_count,created_at")
            .order("member_count", ascending: false)
            .limit(limit)
            .execute()
            .value
    }

    func fetchCommunityById(_ id: UUID) async throws -> Community {
        try await client
            .from("communities")
            .select("id,name,slug,description,is_private,is_nsfw,owner_id,member_count,created_at")
            .eq("id", value: id.uuidString)
            .single()
            .execute()
            .value
    }

    func fetchMyMemberships(userId: UUID) async throws -> [CommunityMembership] {
        try await client
            .from("community_memberships")
            .select("community_id,user_id,role,joined_at")
            .eq("user_id", value: userId.uuidString)
            .execute()
            .value
    }

    func joinCommunity(communityId: UUID, userId: UUID) async throws {
        struct Payload: Encodable { let community_id: UUID; let user_id: UUID }
        _ = try await client
            .from("community_memberships")
            .insert(Payload(community_id: communityId, user_id: userId))
            .execute()
    }

    func leaveCommunity(communityId: UUID, userId: UUID) async throws {
        _ = try await client
            .from("community_memberships")
            .delete()
            .eq("community_id", value: communityId.uuidString)
            .eq("user_id", value: userId.uuidString)
            .execute()
    }

    func createCommunity(
        name: String,
        slug: String,
        description: String?,
        isPrivate: Bool,
        isNsfw: Bool,
        ownerId: UUID
    ) async throws -> Community {
        struct Payload: Encodable {
            let name: String
            let slug: String
            let description: String?
            let is_private: Bool
            let is_nsfw: Bool
            let owner_id: UUID
        }

        return try await client
            .from("communities")
            .insert(Payload(name: name, slug: slug, description: description, is_private: isPrivate, is_nsfw: isNsfw, owner_id: ownerId))
            .select("id,name,slug,description,is_private,is_nsfw,owner_id,member_count,created_at")
            .single()
            .execute()
            .value
    }

    func fetchPostsForCommunity(communityId: UUID, limit: Int = 50) async throws -> [FeedPost] {
        try await client
            .from("posts")
            .select("id,author_id,community_id,title,body,image_url,video_url,is_nsfw,is_pinned,like_count,comment_count,created_at,updated_at")
            .eq("community_id", value: communityId.uuidString)
            .order("created_at", ascending: false)
            .limit(limit)
            .execute()
            .value
    }

    func createPostInCommunity(
        communityId: UUID,
        title: String?,
        body: String?,
        isNsfw: Bool
    ) async throws {
        let user = try await SupabaseManager.client.auth.session.user

        struct Payload: Encodable {
            let author_id: UUID
            let community_id: UUID
            let title: String?
            let body: String?
            let is_nsfw: Bool
        }

        _ = try await client
            .from("posts")
            .insert(Payload(
                author_id: user.id,
                community_id: communityId,
                title: title,
                body: body,
                is_nsfw: isNsfw
            ))
            .execute()
    }
}

