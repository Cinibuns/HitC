//
//  CommentsView.swift
//  HitC
//
//  Created by Matt Symons on 28/1/2026.
//

import SwiftUI

struct CommentsView: View {
    let postId: UUID

    @State private var post: Post?
    @State private var postAuthor: PublicProfile?

    @State private var topLevel: [Comment] = []
    @State private var childrenByParent: [UUID: [Comment]] = [:]

    @State private var isLoading = false
    @State private var errorText: String?

    @State private var replyingTo: UUID? = nil
    @State private var replyText = ""
    @State private var isPostingReply = false

    var body: some View {
        ZStack {
            CloudBackground()

            Group {
                if isLoading {
                    ProgressView("Loading…").tint(.white)
                } else if let errorText {
                    VStack(spacing: 12) {
                        Text("Couldn’t load comments.")
                            .foregroundStyle(.white)
                            .font(.headline)
                        Text(errorText).foregroundStyle(.red).multilineTextAlignment(.center)
                        Button("Retry") { Task { await load() } }
                            .buttonStyle(GradientPrimaryButtonStyle())
                            .padding(.horizontal)
                    }
                    .padding()
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 14) {

                            // Post at top
                            if let post {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text(postAuthor?.displayName ?? postAuthor?.username ?? "Unknown user")
                                        .font(.headline)
                                        .foregroundStyle(.white)

                                    Text(post.isNsfw ? "NSFW" : "SAFE")
                                        .font(.caption.weight(.semibold))
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(
                                            Capsule().fill((post.isNsfw ? Color.pink : Color.green).opacity(0.22))
                                        )
                                        .overlay(Capsule().stroke(Color.white.opacity(0.16), lineWidth: 1))
                                        .foregroundStyle(.white.opacity(0.9))

                                    Text("💬 \(post.commentCount) comments")
                                        .font(.caption)
                                        .foregroundStyle(Theme.textSecondary)
                                }
                                .padding(14)
                                .background(Theme.card())
                                .padding(.horizontal)
                            }

                            // Reply composer
                            if let parentId = replyingTo {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("Replying…").font(.caption.weight(.semibold)).foregroundStyle(Theme.textSecondary)

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
                                        .frame(maxWidth: 170)
                                        .disabled(isPostingReply || replyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                                    }
                                }
                                .padding(14)
                                .background(Theme.card())
                                .padding(.horizontal)
                            }

                            // Thread
                            VStack(alignment: .leading, spacing: 12) {
                                ForEach(topLevel) { c in
                                    ForEach(topLevel) { c in
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

                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 24)
                        }
                        .padding(.top, 10)
                    }
                }
            }
        }
        .navigationTitle("Comments")
        .toolbarBackground(.hidden, for: .navigationBar)
        .task { await load() }
    }

    private func load() async {
        isLoading = true
        defer { isLoading = false }
        errorText = nil

        do {
            let fetchedPost = try await PostService.fetchPost(id: postId)
            post = fetchedPost

            let postAuthors = try await PublicProfileService.fetchProfiles(ids: [fetchedPost.authorId])
            postAuthor = postAuthors.first

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

            childrenByParent = byParent
            topLevel = tops
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
            await load()
        } catch {
            errorText = error.localizedDescription
        }
    }
}
