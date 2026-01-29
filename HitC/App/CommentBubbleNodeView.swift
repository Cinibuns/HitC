//
//  CommentBubbleNodeView.swift
//  HitC
//
//  Created by Matt Symons on 28/1/2026.
//

import SwiftUI

struct CommentBubbleNodeView: View {
    let comment: Comment
    let childrenByParent: [UUID: [Comment]]
    let depth: Int
    let onReplyTapped: (UUID) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            VStack(alignment: .leading, spacing: 8) {
                Text(comment.body ?? "")
                    .foregroundStyle(Theme.textPrimary)

                HStack(spacing: 10) {
                    Button("Reply") { onReplyTapped(comment.id) }
                        .buttonStyle(SoftSecondaryButtonStyle())

                    Spacer()

                    Text(comment.authorId.uuidString.prefix(8) + "…")
                        .font(.caption2)
                        .foregroundStyle(Theme.textSecondary)
                }
            }
            .padding(12)
            .background(BubbleBackground(isReply: depth > 0))

            if let kids = childrenByParent[comment.id], !kids.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(kids) { child in
                        CommentBubbleNodeView(
                            comment: child,
                            childrenByParent: childrenByParent,
                            depth: depth + 1,
                            onReplyTapped: onReplyTapped
                        )
                        .padding(.leading, 14)
                    }
                }
            }
        }
    }
}
