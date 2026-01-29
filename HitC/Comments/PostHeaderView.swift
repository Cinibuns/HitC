//
//  PostHeaderView.swift
//  HitC
//
//  Created by Matt Symons on 28/1/2026.
//

import SwiftUI

struct PostHeaderView: View {
    let post: Post
    let author: PublicProfile?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(author?.displayName ?? author?.username ?? "Unknown user")
                        .font(.headline)
                        .foregroundStyle(Theme.textPrimary)

                    Text(post.createdAt?.formatted(date: .abbreviated, time: .shortened) ?? "")
                        .font(.caption2)
                        .foregroundStyle(Theme.textSecondary)
                }

                Spacer()

                Text(post.isNsfw ? "NSFW" : "SAFE")
                    .font(.caption2.weight(.semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        Capsule().fill((post.isNsfw ? Color.pink : Color.green).opacity(0.20))
                    )
                    .overlay(Capsule().stroke(Color.white.opacity(0.70), lineWidth: 1))
                    .foregroundStyle(Theme.textPrimary)
            }

            Text("💬 \(post.commentCount) comments")
                .font(.caption)
                .foregroundStyle(Theme.textSecondary)
        }
        .padding(16)
        .background(Theme.lightCard())
    }
}
