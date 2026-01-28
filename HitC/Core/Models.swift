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

    var is18Plus: Bool?
    var nsfwEnabled: Bool?
    var blurNsfw: Bool?
}
