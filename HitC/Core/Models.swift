//
//  Models.swift
//  HitC
//
//  Created by Matt Symons on 28/1/2026.
//

import Foundation

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

struct Post: Codable, Identifiable {
    let id: UUID
    let authorId: UUID
    let communityId: UUID?
    let isNsfw: Bool
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case authorId = "author_id"
        case communityId = "community_id"
        case isNsfw = "is_nsfw"
        case createdAt = "created_at"
    }
}
