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

    @State private var topLevel: [Comment] = []
    @State private var childrenByParent: [UUID: [Comment]] = [:]
    @State private var profilesById: [UUID: PublicProfile] = [:]

    @State private var isLoading = false
    @State private var errorText: String?

    @State private var newCommentText = ""
    @State private var isPostingTopLevel = false

    @State private var replyingTo: UUID? = nil
    @State private var replyText = ""
    @State private var isPostingReply = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            header

            content

            Divider().opacity(0.15)

            if let parentId = replyingTo {
                replyComposer(parentId: parentId)
            } else {
                topLevelComposer
            }
        }
        .padding(14)
        .background(Color.white.opacity(0.55))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.white.opacity(0.70), lineWidth: 1)
        )
        .task { await load() }
        .onChange(of: refreshKey) { _, _ in
            Task { await load() }
        }
    }

    // MARK: - Header / Content

    private var header: some View {
        HStack {
            Text("Thread")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.textPrimary)

            Spacer()

            Button {
                Task { await load() }
            } label: {
                Image(systemName: "arrow.clockwise")
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)
            }
            .buttonStyle(.plain)
        }
    }

    @ViewBuilder
    private var content: some View {
        if isLoading {
            ProgressView("Loading comments…")
                .foregroundStyle(Theme.textSecondary)

        } else if let errorText {
            VStack(alignment: .leading, spacing: 8) {
                Text("Couldn’t load comments.")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Theme.textPrimary)

                Text(errorText)
                    .font(.caption)
                    .foregroundStyle(.red)

                Button("Retry") { Task { await load() } }
                    .buttonStyle(NeonRingPrimaryButtonStyle())
            }

        } else if topLevel.isEmpty {
            Text("No comments yet. Be the first 🙂")
                .font(.caption)
                .foregroundStyle(Theme.textSecondary)

        } else {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(topLevel) { c in
                    CommentThreadView(
                        postId: postId,
                        comment: c,
                        childrenByParent: childrenByParent,
                        depth: 0,
                        profilesById: profilesById,
                        onReplyTapped: { id in
                            replyingTo = id
                            replyText = ""
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        }
                    )
                }
            }
        }
    }

    // MARK: - Composers

    private var topLevelComposer: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Add a comment")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Theme.textSecondary)

            HStack(spacing: 10) {
                TextField("Write something…", text: $newCommentText, axis: .vertical)
                    .lineLimit(1...4)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color.white.opacity(0.75))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(Color.white.opacity(0.70), lineWidth: 1)
                    )
                    .foregroundStyle(Theme.textPrimary)

                Button {
                    Task { await postTopLevel() }
                } label: {
                    if isPostingTopLevel {
                        ProgressView().tint(Theme.textPrimary).padding(10)
                    } else {
                        Image(systemName: "paperplane.fill")
                            .foregroundStyle(Theme.textPrimary)
                            .padding(10)
                    }
                }
                .background(Color.white.opacity(0.75))
                .clipShape(Circle())
                .buttonStyle(.plain)
                .disabled(isPostingTopLevel || newCommentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
    }

    private func replyComposer(parentId: UUID) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Replying…")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Theme.textSecondary)

                Spacer()

                Button("Cancel") {
                    replyingTo = nil
                    replyText = ""
                }
                .font(.caption.weight(.semibold))
                .foregroundStyle(Theme.textSecondary)
            }

            HStack(spacing: 10) {
                TextField("Write a reply…", text: $replyText, axis: .vertical)
                    .lineLimit(1...4)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color.white.opacity(0.75))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(Color.white.opacity(0.70), lineWidth: 1)
                    )
                    .foregroundStyle(Theme.textPrimary)

                Button {
                    Task { await postReply(parentId: parentId) }
                } label: {
                    if isPostingReply {
                        ProgressView().tint(Theme.textPrimary).padding(10)
                    } else {
                        Image(systemName: "arrowshape.turn.up.left.fill")
                            .foregroundStyle(Theme.textPrimary)
                            .padding(10)
                    }
                }
                .background(Color.white.opacity(0.75))
                .clipShape(Circle())
                .buttonStyle(.plain)
                .disabled(isPostingReply || replyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
    }

    // MARK: - Data

    private func load() async {
        isLoading = true
        defer { isLoading = false }
        errorText = nil

        do {
            let rows = try await CommentService.fetchAllComments(postId: postId, limit: 2000)

            var byParent: [UUID: [Comment]] = [:]
            var tops: [Comment] = []

            for c in rows {
                if let parent = c.parentCommentId {
                    byParent[parent, default: []].append(c)
                } else {
                    tops.append(c)
                }
            }

            // sort (keeps UI stable)
            for (k, v) in byParent {
                byParent[k] = v.sorted { ($0.createdAt ?? .distantPast) < ($1.createdAt ?? .distantPast) }
            }
            tops = tops.sorted { ($0.createdAt ?? .distantPast) < ($1.createdAt ?? .distantPast) }

            childrenByParent = byParent
            topLevel = tops

            let ids = Array(Set(rows.map(\.authorId)))
            let missing = ids.filter { profilesById[$0] == nil }
            if !missing.isEmpty {
                let profiles = try await PublicProfileService.fetchProfiles(ids: missing)
                for p in profiles { profilesById[p.id] = p }
            }
        } catch {
            errorText = error.localizedDescription
        }
    }

    private func postTopLevel() async {
        let text = newCommentText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, !isPostingTopLevel else { return }

        isPostingTopLevel = true
        defer { isPostingTopLevel = false }
        errorText = nil

        do {
            try await CommentService.addTopLevelComment(postId: postId, body: text)
            newCommentText = ""
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            onPosted()
            await load()
        } catch {
            errorText = error.localizedDescription
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        }
    }

    private func postReply(parentId: UUID) async {
        let text = replyText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, !isPostingReply else { return }

        isPostingReply = true
        defer { isPostingReply = false }
        errorText = nil

        do {
            try await CommentService.addReply(postId: postId, parentCommentId: parentId, body: text)
            replyingTo = nil
            replyText = ""
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            onPosted()
            await load()
        } catch {
            errorText = error.localizedDescription
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        }
    }
}
