//
//  Community.swift
//  HitC
//
//  Created by Matt Symons on 3/2/2026.
//

import Foundation

struct Community: Codable, Identifiable, Hashable {
    let id: UUID
    let name: String
    let slug: String
    let description: String?
    let is_private: Bool
    let is_nsfw: Bool
    let owner_id: UUID
    let member_count: Int
    let created_at: Date
}
