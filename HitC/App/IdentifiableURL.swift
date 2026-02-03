//
//  IdentifiableURL.swift
//  HitC
//
//  Created by Matt Symons on 3/2/2026.
//

import Foundation

struct IdentifiableURL: Identifiable {
    let id: String
    let url: URL

    init(_ url: URL) {
        self.url = url
        self.id = url.absoluteString
    }
}
