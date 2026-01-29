//
//  HomeView.swift
//  HitC
//
//  Created by Matt Symons on 28/1/2026.
//

import SwiftUI

struct IdentifiableURL: Identifiable {
    let id: String
    let url: URL
    init(_ url: URL) {
        self.url = url
        self.id = url.absoluteString
    }
}

struct HomeView: View {
    @EnvironmentObject var appState: AppState

    @State private var posts: [Post] = []
    @State private var authorsById: [UUID: PublicProfile] = [:]
    @State private var likedByPostId: [UUID: Bool] = [:]
    @State private var expandedComments: Set<UUID> = []

    @State private var isLoading = false
    @State private var errorText: String?

    @State private var selectedImage: IdentifiableURL?

    var body: some View {
        NavigationView {
            ZStack {
                LightCloudBackground()

                Group {
                    if isLoading && posts.isEmpty {
                        ProgressView("Loading feed…")

                    } else if let errorText, posts.isEmpty {
                        VStack(spacing: 12) {
                            Text("Couldn’t load feed.")
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
                        List {
                            ForEach(posts) { post in
                                let author = authorsById[post.authorId]
                                let displayName = author?.displayName ?? author?.username ?? "Unknown user"
                                let liked = likedByPostId[post.id] ?? false
                                let isExpanded = expandedComments.contains(post.id)

                                PostRowView(
                                    post: post,
                                    displayName: displayName,
                                    liked: liked,
                                    isExpanded: isExpanded,
                                    onToggleExpand: {
                                        withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
                                            if isExpanded { expandedComments.remove(post.id) }
                                            else { expandedComments.insert(post.id) }
                                        }
                                    },
                                    onToggleLike: {
                                        Task { await toggleLike(postId: post.id) }
                                    },
                                    onCommentPosted: {
                                        if let idx = posts.firstIndex(where: { $0.id == post.id }) {
                                            let p = posts[idx]
                                            posts[idx] = Post(
                                                id: p.id,
                                                authorId: p.authorId,
                                                communityId: p.communityId,
                                                isNsfw: p.isNsfw,
                                                commentCount: p.commentCount + 1,
                                                createdAt: p.createdAt,
                                                imageUrl: p.imageUrl
                                            )
                                        }
                                    },
                                    onImageTapped: { url in
                                        selectedImage = IdentifiableURL(url)
                                    }
                                )
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
            .navigationBarHidden(true)
            .task { await load() }
            .fullScreenCover(item: $selectedImage) { item in
                ImageViewerView(url: item.url)
            }
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

            let missingAuthors = feed.map(\.authorId).filter { authorsById[$0] == nil }
            if !missingAuthors.isEmpty {
                let profiles = try await PublicProfileService.fetchProfiles(ids: missingAuthors)
                for p in profiles { authorsById[p.id] = p }
            }

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
