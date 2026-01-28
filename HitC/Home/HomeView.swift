//
//  HomeView.swift
//  HitC
//
//  Created by Matt Symons on 28/1/2026.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appState: AppState

    @State private var posts: [Post] = []
    @State private var authorsById: [UUID: PublicProfile] = [:]
    @State private var likedByPostId: [UUID: Bool] = [:]
    @State private var expandedComments: Set<UUID> = []

    @State private var isLoading = false
    @State private var errorText: String?

    var body: some View {
        NavigationView {
            ZStack {
                CloudBackground()

                Group {
                    if isLoading && posts.isEmpty {
                        ProgressView("Loading feed…")
                            .tint(.white)
                    } else if let errorText, posts.isEmpty {
                        VStack(spacing: 12) {
                            Text("Couldn’t load feed.")
                                .font(.headline)
                                .foregroundStyle(.white)

                            Text(errorText)
                                .foregroundStyle(.red)
                                .multilineTextAlignment(.center)

                            Button("Retry") { Task { await load() } }
                                .buttonStyle(GradientPrimaryButtonStyle())
                                .padding(.horizontal)
                        }
                        .padding()
                    } else {
                        List {
                            ForEach(posts) { post in
                                let author = authorsById[post.authorId]
                                let displayName = author?.displayName ?? author?.username ?? "Unknown user"
                                let liked = likedByPostId[post.id] ?? false
                                let isExpanded = expandedComments.contains(post.id)

                                VStack(alignment: .leading, spacing: 12) {

                                    // HEADER (tap target only)
                                    VStack(alignment: .leading, spacing: 10) {
                                        HStack {
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(displayName)
                                                    .font(.headline)
                                                    .foregroundStyle(.white)

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
                                                    Capsule()
                                                        .fill((post.isNsfw ? Color.pink : Color.green).opacity(0.22))
                                                )
                                                .overlay(
                                                    Capsule().stroke(Color.white.opacity(0.16), lineWidth: 1)
                                                )
                                                .foregroundStyle(.white.opacity(0.9))
                                        }

                                        // Comment count shows only when collapsed
                                        if !isExpanded {
                                            Text("💬 \(post.commentCount)  •  Tap to view thread")
                                                .font(.caption)
                                                .foregroundStyle(Theme.textSecondary)
                                        } else {
                                            Text("Tap to hide thread")
                                                .font(.caption)
                                                .foregroundStyle(Theme.textSecondary)
                                        }

                                        HStack(spacing: 10) {
                                            Button {
                                                Task { await toggleLike(postId: post.id) }
                                            } label: {
                                                HStack(spacing: 6) {
                                                    Image(systemName: liked ? "heart.fill" : "heart")
                                                    Text(liked ? "Liked" : "Like")
                                                }
                                                .font(.caption.weight(.semibold))
                                                .foregroundStyle(.white)
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 9)
                                                .background(Theme.pill())
                                            }
                                            .buttonStyle(.plain)
                                        }
                                    }
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
                                            if isExpanded { expandedComments.remove(post.id) }
                                            else { expandedComments.insert(post.id) }
                                        }
                                    }

                                    // COMMENTS (not tappable to collapse)
                                    if isExpanded {
                                        InlineCommentsView(
                                            postId: post.id,
                                            refreshKey: 0,
                                            onPosted: {
                                                // instant UI bump for count
                                                if let idx = posts.firstIndex(where: { $0.id == post.id }) {
                                                    let p = posts[idx]
                                                    posts[idx] = Post(
                                                        id: p.id,
                                                        authorId: p.authorId,
                                                        communityId: p.communityId,
                                                        isNsfw: p.isNsfw,
                                                        commentCount: p.commentCount + 1,
                                                        createdAt: p.createdAt
                                                    )
                                                }
                                            }
                                        )
                                        .padding(.top, 4)
                                    }
                                }
                                .padding(14)
                                .background(Theme.card())
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                                .padding(.vertical, 6)
                            }
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                        .refreshable { await load() }
                    }
                }
            }
            .navigationTitle("")
            .toolbar {
                ToolbarItem(placement: .principal) {
                    CloudTitle(text: "Home", subtitle: "Head in the Clouds")
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .task { await load() }
        }
    }

    private func load() async {
        guard appState.profile?.is18Plus == true else {
            posts = []
            errorText = "18+ confirmation required."
            return
        }

        isLoading = true
        defer { isLoading = false }
        errorText = nil

        do {
            let feed = try await PostService.fetchFeed()
            posts = feed

            // authors cache
            let missingAuthors = feed.map(\.authorId).filter { authorsById[$0] == nil }
            if !missingAuthors.isEmpty {
                let profiles = try await PublicProfileService.fetchProfiles(ids: missingAuthors)
                for p in profiles { authorsById[p.id] = p }
            }

            // like status
            for p in feed {
                likedByPostId[p.id] = try await LikeService.hasLiked(postId: p.id)
            }
        } catch {
            errorText = error.localizedDescription
        }
    }

    private func toggleLike(postId: UUID) async {
        let currentlyLiked = likedByPostId[postId] ?? false
        do {
            try await LikeService.toggleLike(postId: postId, liked: currentlyLiked)
            likedByPostId[postId] = !currentlyLiked
        } catch {
            errorText = error.localizedDescription
        }
    }
}
