//
//  Post.swift
//  HitC
//
//  Created by Matt Symons on 3/2/2026.
//

import Foundation

// Renamed from `Post` to avoid conflict with other frameworks/types in your app.
struct FeedPost: Codable, Identifiable, Hashable {
    let id: UUID
    let author_id: UUID
    let community_id: UUID?
    let title: String?
    let body: String?
    let image_url: String?
    let video_url: String?
    let is_nsfw: Bool
    let is_pinned: Bool
    let like_count: Int
    let comment_count: Int
    let created_at: Date
    let updated_at: Date
}
