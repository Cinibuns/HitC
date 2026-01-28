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

    let onReplyTapped: (UUID) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            VStack(alignment: .leading, spacing: 4) {
                Text(comment.body ?? "")
                Text(comment.authorId.uuidString)
                    .font(.caption2)
                    .opacity(0.55)
            }

            Button("Reply") {
                onReplyTapped(comment.id)
            }
            .font(.caption)
            .buttonStyle(.bordered)

            if let kids = childrenByParent[comment.id], !kids.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(kids) { child in
                        CommentThreadView(
                            postId: postId,
                            comment: child,
                            childrenByParent: childrenByParent,
                            depth: depth + 1,
                            onReplyTapped: onReplyTapped
                        )
                        .padding(.leading, 14) // indentation per depth
                    }
                }
                .padding(.top, 6)
            }
        }
        .padding(.vertical, 6)
    }
}
