//
//  CommentsView.swift
//  HitC
//
//  Created by Matt Symons on 28/1/2026.
//

import SwiftUI

struct InlineCommentsView: View {
    let postId: UUID
    let refreshKey: Int
    let onPosted: () -> Void

    private let maxTopLevel = 5

    @State private var topLevel: [Comment] = []
    @State private var childrenByParent: [UUID: [Comment]] = [:]
    @State private var hasMoreTopLevel = false

    @State private var isLoading = false
    @State private var errorText: String?

    @State private var newComment = ""
    @State private var isPosting = false

    @State private var replyingTo: UUID? = nil
    @State private var replyText = ""
    @State private var isPostingReply = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            // Add comment composer
            VStack(alignment: .leading, spacing: 10) {
                TextField("Add a comment…", text: $newComment, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(1...4)
                    .tint(.white)
                    .foregroundStyle(.white)
                    .scrollContentBackground(.hidden)
                    .background(Color.white.opacity(0.10))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                Button {
                    Task { await postTopLevel() }
                } label: {
                    if isPosting { ProgressView().tint(.white) } else { Text("Post") }
                }
                .buttonStyle(GradientPrimaryButtonStyle())
                .disabled(isPosting || newComment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(12)
            .background(Theme.card())
            .padding(.top, 2)

            // Reply composer (shows when replying)
            if let parentId = replyingTo {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Replying…")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Theme.textSecondary)

                    TextField("Write a reply…", text: $replyText, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(1...4)

                    HStack(spacing: 10) {
                        Button("Cancel") {
                            replyingTo = nil
                            replyText = ""
                        }
                        .buttonStyle(SoftButtonStyle())

                        Spacer()

                        Button {
                            Task { await postReply(parentId: parentId) }
                        } label: {
                            if isPostingReply { ProgressView().tint(.white) } else { Text("Reply") }
                        }
                        .buttonStyle(GradientPrimaryButtonStyle())
                        .frame(maxWidth: 160)
                        .disabled(isPostingReply || replyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
                .padding(12)
                .background(Theme.card())
            }

            // Comments list area
            if isLoading {
                ProgressView("Loading comments…")
                    .tint(.white)
            } else if let errorText {
                Text(errorText).foregroundStyle(.red).font(.caption)
                Button("Retry") { Task { await load() } }
                    .buttonStyle(SoftButtonStyle())
            } else if topLevel.isEmpty {
                Text("No comments yet.")
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)
            } else {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(topLevel.prefix(maxTopLevel)) { c in
                        CommentBubbleNode(
                            comment: c,
                            childrenByParent: childrenByParent,
                            depth: 0,
                            onReplyTapped: { id in
                                replyingTo = id
                                replyText = ""
                            }
                        )
                    }

                    if hasMoreTopLevel {
                        NavigationLink {
                            CommentsView(postId: postId)
                        } label: {
                            HStack(spacing: 8) {
                                Text("See all comments")
                                Image(systemName: "chevron.right")
                            }
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.white)
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity)
                            .background(Theme.pill())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .onChange(of: refreshKey) { _, _ in
            Task { await load() }
        }
        .task { await load() }
    }

    private func load() async {
        isLoading = true
        defer { isLoading = false }
        errorText = nil

        do {
            let rows = try await CommentService.fetchAllComments(postId: postId, limit: 600)

            var byParent: [UUID: [Comment]] = [:]
            var tops: [Comment] = []

            for c in rows {
                if let parent = c.parentCommentId {
                    byParent[parent, default: []].append(c)
                } else {
                    tops.append(c)
                }
            }

            hasMoreTopLevel = tops.count > maxTopLevel
            childrenByParent = byParent
            topLevel = tops
        } catch {
            errorText = error.localizedDescription
        }
    }

    private func postTopLevel() async {
        let text = newComment.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        isPosting = true
        defer { isPosting = false }
        errorText = nil

        do {
            try await CommentService.addTopLevelComment(postId: postId, body: text)
            newComment = ""
            onPosted()
            await load()
        } catch {
            errorText = error.localizedDescription
        }
    }

    private func postReply(parentId: UUID) async {
        let text = replyText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        isPostingReply = true
        defer { isPostingReply = false }
        errorText = nil

        do {
            try await CommentService.addReply(postId: postId, parentCommentId: parentId, body: text)
            replyingTo = nil
            replyText = ""
            onPosted()
            await load()
        } catch {
            errorText = error.localizedDescription
        }
    }
}

// MARK: - Recursive bubble nodes

private struct CommentBubbleNode: View {
    let comment: Comment
    let childrenByParent: [UUID: [Comment]]
    let depth: Int
    let onReplyTapped: (UUID) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            VStack(alignment: .leading, spacing: 8) {
                Text(comment.body ?? "")
                    .foregroundStyle(.white)

                HStack(spacing: 10) {
                    Button("Reply") { onReplyTapped(comment.id) }
                        .buttonStyle(SoftButtonStyle())

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
                        CommentBubbleNode(
                            comment: child,
                            childrenByParent: childrenByParent,
                            depth: depth + 1,
                            onReplyTapped: onReplyTapped
                        )
                        .padding(.leading, 14) // indentation
                    }
                }
            }
        }
    }
}
