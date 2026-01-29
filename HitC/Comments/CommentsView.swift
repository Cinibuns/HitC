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

    // Reply composer
    @State private var replyingTo: UUID? = nil
    @State private var replyText = ""
    @State private var isPostingReply = false

    var body: some View {
        NavigationView {
            ZStack {
                LightCloudBackground()

                Group {
                    if isLoading {
                        ProgressView("Loading…")

                    } else if let errorText {
                        VStack(spacing: 12) {
                            Text("Couldn’t load comments.")
                                .font(.headline)
                                .foregroundStyle(Theme.textPrimary)

                            Text(errorText)
                                .foregroundStyle(.red)
                                .multilineTextAlignment(.center)

                            Button("Retry") { Task { await load() } }
                                .buttonStyle(NeonRingPrimaryButtonStyle())
                                .padding(.horizontal)
                        }
                        .padding()

                    } else {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 14) {

                                // Post at top
                                if let post {
                                    PostHeaderView(post: post, author: postAuthor)
                                        .padding(.horizontal)
                                }

                                // Reply composer (shows only when replying)
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
                                                if isPostingReply {
                                                    ProgressView().tint(.white)
                                                } else {
                                                    Text("Reply")
                                                }
                                            }
                                            .buttonStyle(NeonRingPrimaryButtonStyle())
                                            .frame(maxWidth: 170)
                                            .disabled(isPostingReply || replyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                                        }
                                    }
                                    .padding(18)
                                    .background(Theme.lightCard())
                                    .padding(.horizontal)
                                }

                                // Thread
                                VStack(alignment: .leading, spacing: 12) {
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
                                .padding(.horizontal)
                                .padding(.bottom, 24)
                            }
                            .padding(.top, 10)
                        }
                    }
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .task { await load() }
        }
    }

    private func load() async {
        isLoading = true
        defer { isLoading = false }
        errorText = nil

        do {
            // Post header
            let fetchedPost = try await PostService.fetchPost(id: postId)
            post = fetchedPost

            let postAuthors = try await PublicProfileService.fetchProfiles(ids: [fetchedPost.authorId])
            postAuthor = postAuthors.first

            // All comments -> build tree
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
