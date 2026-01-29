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

            // Add comment
            VStack(alignment: .leading, spacing: 10) {
                TextField("Add a comment…", text: $newComment, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(1...4)

                Button {
                    Task { await postTopLevel() }
                } label: {
                    if isPosting { ProgressView().tint(.white) } else { Text("Post") }
                }
                .buttonStyle(NeonRingPrimaryButtonStyle())
                .disabled(isPosting || newComment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(14)
            .background(Theme.lightCard())

            // Reply box
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
                        .buttonStyle(SoftSecondaryButtonStyle())

                        Spacer()

                        Button {
                            Task { await postReply(parentId: parentId) }
                        } label: {
                            if isPostingReply { ProgressView().tint(.white) } else { Text("Reply") }
                        }
                        .buttonStyle(NeonRingPrimaryButtonStyle())
                        .frame(maxWidth: 170)
                        .disabled(isPostingReply || replyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
                .padding(14)
                .background(Theme.lightCard())
            }

            // List
            if isLoading {
                ProgressView("Loading comments…")
            } else if let errorText {
                Text(errorText).foregroundStyle(.red).font(.caption)
                Button("Retry") { Task { await load() } }
                    .buttonStyle(SoftSecondaryButtonStyle())
            } else if topLevel.isEmpty {
                Text("No comments yet.")
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)
            } else {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(topLevel.prefix(maxTopLevel)) { c in
                        CommentBubbleNodeView(
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
                            Text("See all comments")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(Theme.textPrimary)
                                .padding(.vertical, 10)
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .fill(Color.white.opacity(0.70))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                                .stroke(Color.white.opacity(0.70), lineWidth: 1)
                                        )
                                )
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
