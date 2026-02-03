//
//  CommunityMembership.swift
//  HitC
//
//  Created by Matt Symons on 3/2/2026.
//

import Foundation

struct CommunityMembership: Codable, Hashable {
    let community_id: UUID
    let user_id: UUID
    let role: String
    let joined_at: Date
}
