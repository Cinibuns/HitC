//
//  CommunitiesViewModel.swift
//  HitC
//
//  Created by Matt Symons on 3/2/2026.
//

import Foundation
import SwiftUI
import Combine
import Supabase

@MainActor
final class CommunitiesViewModel: ObservableObject {
    @Published var communities: [Community] = []
    @Published var joinedCommunityIds: Set<UUID> = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    @Published var showCreateCommunity = false

    private let service = CommunitiesService()

    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let user = try await SupabaseManager.shared.client.auth.session.user
            let userId = user.id

            async let comms = service.fetchCommunities()
            async let memberships = service.fetchMyMemberships(userId: userId)

            let (all, mine) = try await (comms, memberships)
            communities = all
            joinedCommunityIds = Set(mine.map { $0.community_id })
        } catch {
            errorMessage = "Couldn’t load communities: \(error.localizedDescription)"
        }
    }

    func isJoined(_ community: Community) -> Bool {
        joinedCommunityIds.contains(community.id)
    }

    func toggleJoin(_ community: Community) async {
        do {
            let user = try await SupabaseManager.shared.client.auth.session.user
            let userId = user.id

            if isJoined(community) {
                try await service.leaveCommunity(communityId: community.id, userId: userId)
                joinedCommunityIds.remove(community.id)
            } else {
                try await service.joinCommunity(communityId: community.id, userId: userId)
                joinedCommunityIds.insert(community.id)
            }

            communities = try await service.fetchCommunities()
        } catch {
            errorMessage = "Join/leave failed: \(error.localizedDescription)"
        }
    }

    func createCommunity(name: String, slug: String, description: String?, isPrivate: Bool, isNsfw: Bool) async -> Community? {
        do {
            let user = try await SupabaseManager.shared.client.auth.session.user
            let created = try await service.createCommunity(
                name: name,
                slug: slug,
                description: description,
                isPrivate: isPrivate,
                isNsfw: isNsfw,
                ownerId: user.id
            )
            await load()
            return created
        } catch {
            errorMessage = "Create community failed: \(error.localizedDescription)"
            return nil
        }
    }
}
