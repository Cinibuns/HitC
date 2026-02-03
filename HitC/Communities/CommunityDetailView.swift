//
//  CommunityDetailView.swift
//  HitC
//
//  Created by Matt Symons on 3/2/2026.
//

import SwiftUI
import Combine
import Supabase

@MainActor
final class CommunityDetailViewModel: ObservableObject {
    @Published var community: Community
    @Published var isJoined: Bool

    @Published var posts: [FeedPost] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    @Published var isJoinLeaveBusy = false
    @Published var showCreatePost = false
    @Published var isPosting = false

    // Home-style state
    @Published var authorsById: [UUID: PublicProfile] = [:]
    @Published var likedByPostId: [UUID: Bool] = [:]
    @Published var expandedComments: Set<UUID> = []

    private let service = CommunitiesService()

    init(community: Community, isJoined: Bool) {
        self.community = community
        self.isJoined = isJoined
    }

    func loadAll() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let user = try await SupabaseManager.client.auth.session.user
            let userId = user.id

            async let freshCommunity = service.fetchCommunityById(community.id)
            async let myMemberships = service.fetchMyMemberships(userId: userId)
            async let communityPosts = service.fetchPostsForCommunity(communityId: community.id)

            let (c, memberships, p) = try await (freshCommunity, myMemberships, communityPosts)

            community = c
            isJoined = memberships.contains(where: { $0.community_id == community.id })
            posts = p

            // Authors
            let authorIds = Array(Set(p.map(\.author_id)))
            let missing = authorIds.filter { authorsById[$0] == nil }
            if !missing.isEmpty {
                let profiles = try await PublicProfileService.fetchProfiles(ids: missing)
                for prof in profiles { authorsById[prof.id] = prof }
            }

            // Like state
            for post in p {
                likedByPostId[post.id] = try await LikeService.hasLiked(postId: post.id)
            }

        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func toggleJoinLeave() async throws {
        guard !isJoinLeaveBusy else { return }
        isJoinLeaveBusy = true
        defer { isJoinLeaveBusy = false }

        let user = try await SupabaseManager.client.auth.session.user
        let userId = user.id

        if isJoined {
            try await service.leaveCommunity(communityId: community.id, userId: userId)
            isJoined = false
        } else {
            try await service.joinCommunity(communityId: community.id, userId: userId)
            isJoined = true
        }

        await loadAll()
    }

    func createPost(title: String?, body: String?, isNsfw: Bool) async -> Bool {
        guard isJoined, !isPosting else { return false }
        isPosting = true
        defer { isPosting = false }

        do {
            try await service.createPostInCommunity(
                communityId: community.id,
                title: title,
                body: body,
                isNsfw: isNsfw
            )
            await loadAll()
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func toggleLike(postId: UUID) async {
        let currentlyLiked = likedByPostId[postId] ?? false
        do {
            try await LikeService.toggleLike(postId: postId, liked: currentlyLiked)
            likedByPostId[postId] = !currentlyLiked
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func incrementCommentCount(for postId: UUID) {
        if let idx = posts.firstIndex(where: { $0.id == postId }) {
            let p = posts[idx]
            posts[idx] = FeedPost(
                id: p.id,
                author_id: p.author_id,
                community_id: p.community_id,
                title: p.title,
                body: p.body,
                image_url: p.image_url,
                video_url: p.video_url,
                is_nsfw: p.is_nsfw,
                is_pinned: p.is_pinned,
                like_count: p.like_count,
                comment_count: p.comment_count + 1,
                created_at: p.created_at,
                updated_at: p.updated_at
            )
        }
    }
}

struct CommunityDetailView: View {
    @EnvironmentObject var appState: AppState

    @StateObject private var vm: CommunityDetailViewModel
    private let onMembershipChanged: (() -> Void)?

    @State private var selectedImage: IdentifiableURL?

    private var cloudsGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 1.00, green: 0.35, blue: 0.62),
                Color(red: 0.49, green: 0.36, blue: 1.00),
                Color(red: 0.23, green: 0.67, blue: 1.00)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    init(
        community: Community,
        isJoined: Bool,
        onMembershipChanged: (() -> Void)? = nil
    ) {
        _vm = StateObject(wrappedValue: CommunityDetailViewModel(community: community, isJoined: isJoined))
        self.onMembershipChanged = onMembershipChanged
    }

    var body: some View {
        ZStack {
            LightCloudBackground()
                .allowsHitTesting(false)

            ScrollView {
                VStack(spacing: 14) {
                    headerCard
                    postsCard
                    Spacer(minLength: 24)
                }
                .padding(.horizontal)
                .padding(.top, 14)
            }
        }
        .safeAreaInset(edge: .bottom) { bottomCTA }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .task { await vm.loadAll() }
        .refreshable { await vm.loadAll() }
        .sheet(isPresented: $vm.showCreatePost) {
            CreatePostView { payload in
                await vm.createPost(title: payload.title, body: payload.body, isNsfw: payload.isNsfw)
            }
            .presentationDetents([.medium, .large])
        }
        .fullScreenCover(item: $selectedImage) { item in
            ImageViewerView(url: item.url)
        }
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.65))
                        .frame(width: 44, height: 44)
                    Image(systemName: "person.3.fill")
                        .foregroundStyle(cloudsGradient)
                        .font(.headline)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(vm.community.name)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(Theme.textPrimary)

                    Text("/\(vm.community.slug)")
                        .font(.caption)
                        .foregroundStyle(Theme.textSecondary)

                    if let d = vm.community.description, !d.isEmpty {
                        Text(d)
                            .font(.subheadline)
                            .foregroundStyle(Theme.textSecondary)
                    }
                }

                Spacer()

                Button {
                    Task {
                        do {
                            try await vm.toggleJoinLeave()
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            onMembershipChanged?()
                        } catch {
                            vm.errorMessage = error.localizedDescription
                            UINotificationFeedbackGenerator().notificationOccurred(.error)
                        }
                    }
                } label: {
                    HStack(spacing: 8) {
                        if vm.isJoinLeaveBusy {
                            ProgressView().tint(Theme.textPrimary)
                        } else {
                            Image(systemName: vm.isJoined ? "checkmark.circle.fill" : "plus.circle.fill")
                                .foregroundStyle(cloudsGradient)
                            Text(vm.isJoined ? "Joined" : "Join")
                                .foregroundStyle(Theme.textPrimary)
                        }
                    }
                    .font(.subheadline.weight(.semibold))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Color.white.opacity(0.85))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(Color.white.opacity(0.75), lineWidth: 1)
                    )
                }
                .disabled(vm.isJoinLeaveBusy || (vm.community.is_private && !vm.isJoined))
            }

            HStack(spacing: 10) {
                Text("\(vm.community.member_count) members")
                if vm.community.is_private { Text("Private") }
                if vm.community.is_nsfw { Text("Mature") }
                if !vm.isJoined { Text("Not joined").foregroundStyle(.orange) }
            }
            .font(.caption2)
            .foregroundStyle(Theme.textSecondary)

            if let err = vm.errorMessage {
                Text(err)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
        .padding(20)
        .background(Theme.lightCard())
    }

    private var postsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Posts")
                    .font(.headline)
                    .foregroundStyle(Theme.textPrimary)
                Spacer()
            }

            if vm.isLoading && vm.posts.isEmpty {
                ProgressView("Loading posts…")
                    .foregroundStyle(Theme.textSecondary)
                    .padding(.vertical, 12)
            } else if vm.posts.isEmpty {
                Text(vm.isJoined ? "No posts yet." : "Join to see posts.")
                    .font(.subheadline)
                    .foregroundStyle(Theme.textSecondary)
                    .padding(.vertical, 6)
            } else {
                VStack(spacing: 10) {
                    ForEach(vm.posts) { fp in
                        let post = fp.asHomePost()
                        let author = vm.authorsById[post.authorId]
                        let displayName = author?.displayName ?? author?.username ?? "Unknown user"
                        let liked = vm.likedByPostId[post.id] ?? false
                        let isExpanded = vm.expandedComments.contains(post.id)

                        PostRowView(
                            post: post,
                            displayName: displayName,
                            liked: liked,
                            isExpanded: isExpanded,
                            onToggleExpand: {
                                withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
                                    if isExpanded { vm.expandedComments.remove(post.id) }
                                    else { vm.expandedComments.insert(post.id) }
                                }
                            },
                            onToggleLike: {
                                Task { await vm.toggleLike(postId: post.id) }
                            },
                            onCommentPosted: {
                                vm.incrementCommentCount(for: post.id)
                            },
                            onImageTapped: { url in
                                selectedImage = IdentifiableURL(url)
                            }
                        )
                        .padding(.vertical, 6)
                    }
                }
            }
        }
        .padding(20)
        .background(Theme.lightCard())
    }

    private var bottomCTA: some View {
        VStack(spacing: 0) {
            Divider().opacity(0.12)
            HStack {
                Button {
                    vm.showCreatePost = true
                } label: {
                    HStack(spacing: 10) {
                        Text(vm.isPosting ? "Posting…" : "New Post")
                        Image(systemName: "square.and.pencil")
                    }
                }
                .buttonStyle(NeonRingPrimaryButtonStyle())
                .disabled(!vm.isJoined || vm.isPosting)

                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 10)
            .padding(.bottom, 14)
            .background(.ultraThinMaterial)
        }
    }
}

private extension FeedPost {
    func asHomePost() -> Post {
        Post(
            id: id,
            authorId: author_id,
            communityId: community_id,
            isNsfw: is_nsfw,
            commentCount: comment_count,
            createdAt: created_at,
            imageUrl: image_url
        )
    }
}

