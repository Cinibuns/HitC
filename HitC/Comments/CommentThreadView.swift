//
//  CommentThreadView.swift
//  HitC
//
//  Created by Matt Symons on 28/1/2026.
//

import SwiftUI

struct CommentThreadView: View {
    let postId: UUID
    let comment: Comment
    let childrenByParent: [UUID: [Comment]]
    let depth: Int

    let profilesById: [UUID: PublicProfile]
    let onReplyTapped: (UUID) -> Void

    private var displayName: String {
        let p = profilesById[comment.authorId]
        return p?.displayName ?? p?.username ?? "Unknown user"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {

            HStack(alignment: .top, spacing: 10) {
                // Placeholder avatar
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.75))
                        .frame(width: 26, height: 26)
                        .overlay(Circle().stroke(Color.white.opacity(0.70), lineWidth: 1))
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 15))
                        .foregroundStyle(Theme.textSecondary)
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(displayName)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Theme.textPrimary)

                        Spacer()

                        Text(comment.createdAt?.formatted(date: .abbreviated, time: .shortened) ?? "")
                            .font(.caption2)
                            .foregroundStyle(Theme.textSecondary)
                    }

                    Text(comment.body ?? "")
                        .font(.subheadline)
                        .foregroundStyle(Theme.textPrimary)

                    Button {
                        onReplyTapped(comment.id)
                    } label: {
                        Text("Reply")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Theme.textSecondary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.white.opacity(0.55))
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }

            if let kids = childrenByParent[comment.id], !kids.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(kids) { child in
                        CommentThreadView(
                            postId: postId,
                            comment: child,
                            childrenByParent: childrenByParent,
                            depth: depth + 1,
                            profilesById: profilesById,
                            onReplyTapped: onReplyTapped
                        )
                        .padding(.leading, 14)
                    }
                }
                .padding(.top, 6)
            }
        }
        .padding(12)
        .background(Color.white.opacity(0.65))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.white.opacity(0.75), lineWidth: 1)
        )
        .padding(.leading, CGFloat(depth) * 8)
    }
}
