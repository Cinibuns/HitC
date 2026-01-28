//
//  Models.swift
//  HitC
//
//  Created by Matt Symons on 28/1/2026.
//

import Foundation

struct Profile: Codable, Identifiable {
    let id: UUID
    var username: String?
    var displayName: String?
    var avatarUrl: String?
    var bannerUrl: String?
    var bio: String?

    var is18Plus: Bool
    var nsfwEnabled: Bool
    var blurNsfw: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case username
        case displayName = "display_name"
        case avatarUrl = "avatar_url"
        case bannerUrl = "banner_url"
        case bio
        case is18Plus = "is_18_plus"
        case nsfwEnabled = "nsfw_enabled"
        case blurNsfw = "blur_nsfw"
    }
}
