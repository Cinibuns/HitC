//
//  Models.swift
//  HitC
//
//  Created by Matt Symons on 28/1/2026.
//

import Foundation

// MARK: - Profile (self)

struct Profile: Codable, Identifiable {
    let id: UUID
    var is18Plus: Bool
    var nsfwEnabled: Bool
    var blurNsfw: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case is18Plus = "is_18_plus"
        case nsfwEnabled = "nsfw_enabled"
        case blurNsfw = "blur_nsfw"
    }
}

// MARK: - Public profile (other users)

struct PublicProfile: Codable, Identifiable {
    let id: UUID
    let username: String?
    let displayName: String?
    let avatarUrl: String?

    enum CodingKeys: String, CodingKey {
        case id
        case username
        case displayName = "display_name"
        case avatarUrl = "avatar_url"
    }
}

// MARK: - Post

struct Post: Codable, Identifiable {
    let id: UUID
    let authorId: UUID
    let communityId: UUID?
    let isNsfw: Bool
    let commentCount: Int
    let createdAt: Date?
    let imageUrl: String?          // ✅ add

    enum CodingKeys: String, CodingKey {
        case id
        case authorId = "author_id"
        case communityId = "community_id"
        case isNsfw = "is_nsfw"
        case commentCount = "comment_count"
        case createdAt = "created_at"
        case imageUrl = "image_url" // ✅ add
    }
}


// MARK: - Comment

struct Comment: Codable, Identifiable {
    let id: UUID
    let postId: UUID
    let authorId: UUID
    let parentCommentId: UUID?
    let body: String?
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case postId = "post_id"
        case authorId = "author_id"
        case parentCommentId = "parent_comment_id"
        case body
        case createdAt = "created_at"
    }
}


// MARK: - Like

struct PostLike: Codable {
    let postId: UUID
    let userId: UUID

    enum CodingKeys: String, CodingKey {
        case postId = "post_id"
        case userId = "user_id"
    }
}
