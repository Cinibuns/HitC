//
//  PostRowView.swift
//  HitC
//
//  Created by Matt Symons on 29/1/2026.
//

import SwiftUI

struct PostRowView: View {
    @EnvironmentObject var appState: AppState

    let post: Post
    let displayName: String
    let liked: Bool
    let isExpanded: Bool

    let onToggleExpand: () -> Void
    let onToggleLike: () -> Void
    let onCommentPosted: () -> Void
    let onImageTapped: (URL) -> Void

    @State private var isNsfwRevealed = false

    private var blurEnabled: Bool {
        appState.profile?.blurNsfw ?? true
    }

    private var shouldBlur: Bool {
        post.isNsfw && blurEnabled && !isNsfwRevealed
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            // Header (tap target)
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(displayName)
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
                            Capsule().fill((post.isNsfw ? Color.pink : Color.green).opacity(0.18))
                        )
                        .overlay(Capsule().stroke(Color.white.opacity(0.70), lineWidth: 1))
                        .foregroundStyle(Theme.textPrimary)
                }

                Text(isExpanded ? "Tap to hide thread" : "💬 \(post.commentCount)  •  Tap to view thread")
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)

                Button(action: onToggleLike) {
                    HStack(spacing: 6) {
                        Image(systemName: liked ? "heart.fill" : "heart")
                        Text(liked ? "Liked" : "Like")
                    }
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Theme.textPrimary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 9)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color.white.opacity(0.70))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(Color.white.opacity(0.70), lineWidth: 1)
                            )
                    )
                }
                .buttonStyle(.plain)
            }
            .contentShape(Rectangle())
            .onTapGesture { onToggleExpand() }

            // Image (4:3) with NSFW blur + tap-to-reveal
            if let urlString = post.imageUrl, let url = URL(string: urlString) {
                ZStack {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                        default:
                            Rectangle().fill(Color.black.opacity(0.04))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .aspectRatio(4.0/3.0, contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(Color.white.opacity(0.70), lineWidth: 1)
                    )
                    .blur(radius: shouldBlur ? 22 : 0)
                    .animation(.easeOut(duration: 0.22), value: shouldBlur)

                    if shouldBlur {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(Color.black.opacity(0.35))

                        VStack(spacing: 8) {
                            Image(systemName: "eye.slash")
                                .font(.title2)
                            Text("NSFW content")
                                .font(.subheadline.weight(.semibold))
                            Text("Tap to view")
                                .font(.caption)
                                .opacity(0.9)
                        }
                        .foregroundStyle(.white)
                        .padding(14)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    if shouldBlur {
                        isNsfwRevealed = true
                    } else {
                        onImageTapped(url)
                    }
                }
            }

            // Inline comments
            if isExpanded {
                InlineCommentsView(
                    postId: post.id,
                    refreshKey: 0,
                    onPosted: onCommentPosted
                )
                .padding(.top, 4)
            }
        }
        .padding(16)
        .background(Theme.lightCard())
        // reset reveal state when the row is reused for a different post
        .onChange(of: post.id) { _, _ in
            isNsfwRevealed = false
        }
    }
}
