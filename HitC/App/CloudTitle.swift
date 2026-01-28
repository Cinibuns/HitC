//
//  CloudTitle.swift
//  HitC
//
//  Created by Matt Symons on 28/1/2026.
//

import SwiftUI

struct CloudTitle: View {
    let text: String
    var subtitle: String? = nil

    var body: some View {
        VStack(spacing: 2) {
            Text(text)
                .font(.headline.weight(.bold))
                .foregroundStyle(.white)

            if let subtitle {
                Text(subtitle)
                    .font(.caption2)
                    .foregroundStyle(Theme.textSecondary)
            }
        }
    }
}
