//
//  CommunitiesView.swift
//  HitC
//
//  Created by Matt Symons on 3/2/2026.
//

import SwiftUI

struct CommunitiesView: View {
    @StateObject private var vm = CommunitiesViewModel()
    @State private var searchText = ""

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

    private var filteredCommunities: [Community] {
        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else { return vm.communities }
        return vm.communities.filter { c in
            c.name.lowercased().contains(q)
            || c.slug.lowercased().contains(q)
            || (c.description ?? "").lowercased().contains(q)
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LightCloudBackground()
                    .allowsHitTesting(false)

                ScrollView {
                    VStack(spacing: 14) {
                        header

                        if vm.isLoading {
                            loadingCard
                        } else if let err = vm.errorMessage {
                            errorCard(err)
                        } else {
                            communitiesGrid
                        }

                        Spacer(minLength: 24)
                    }
                    .padding(.horizontal)
                    .padding(.top, 14)
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search communities")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        vm.showCreateCommunity = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.headline)
                            .foregroundStyle(cloudsGradient)
                    }
                }
            }
            .sheet(isPresented: $vm.showCreateCommunity) {
                CreateCommunityView { payload in
                    Task {
                        _ = await vm.createCommunity(
                            name: payload.name,
                            slug: payload.slug,
                            description: payload.description,
                            isPrivate: payload.isPrivate,
                            isNsfw: payload.isNsfw
                        )
                        vm.showCreateCommunity = false
                    }
                }
            }
            .task { await vm.load() }
        }
    }

    // MARK: - Pieces

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                Image(systemName: "cloud.fill")
                    .font(.title2)
                    .foregroundStyle(cloudsGradient)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Communities")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(Theme.textPrimary)
                    Text("Find your people ☁️")
                        .font(.subheadline)
                        .foregroundStyle(Theme.textSecondary)
                }

                Spacer()
            }
        }
        .padding(20)
        .background(Theme.lightCard())
    }

    private var loadingCard: some View {
        VStack(spacing: 12) {
            ProgressView("Loading communities…")
                .foregroundStyle(Theme.textSecondary)
        }
        .padding(20)
        .background(Theme.lightCard())
    }

    private func errorCard(_ err: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Something went wrong")
                .font(.headline)
                .foregroundStyle(Theme.textPrimary)

            Text(err)
                .font(.caption)
                .foregroundStyle(.red)

            Button("Retry") { Task { await vm.load() } }
                .buttonStyle(NeonRingPrimaryButtonStyle())
        }
        .padding(20)
        .background(Theme.lightCard())
    }

    private var communitiesGrid: some View {
        LazyVStack(spacing: 12) {
            if filteredCommunities.isEmpty {
                VStack(spacing: 8) {
                    Text("No matches")
                        .font(.headline)
                        .foregroundStyle(Theme.textPrimary)
                    Text("Try searching by name, slug, or description.")
                        .font(.subheadline)
                        .foregroundStyle(Theme.textSecondary)
                }
                .padding(20)
                .background(Theme.lightCard())
            } else {
                ForEach(filteredCommunities) { c in
                    NavigationLink {
                        CommunityDetailView(
                            community: c,
                            isJoined: vm.isJoined(c),
                            onMembershipChanged: { Task { await vm.load() } }
                        )
                    } label: {
                        communityRow(c)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func communityRow(_ c: Community) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.65))
                        .frame(width: 38, height: 38)
                    Image(systemName: "person.3.fill")
                        .foregroundStyle(cloudsGradient)
                        .font(.headline)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(c.name)
                        .font(.headline)
                        .foregroundStyle(Theme.textPrimary)

                    Text("/\(c.slug)")
                        .font(.caption)
                        .foregroundStyle(Theme.textSecondary)

                    if let d = c.description, !d.isEmpty {
                        Text(d)
                            .font(.subheadline)
                            .foregroundStyle(Theme.textSecondary)
                            .lineLimit(2)
                    }
                }

                Spacer()

                Button {
                    Task { await vm.toggleJoin(c) }
                } label: {
                    Text(vm.isJoined(c) ? "Joined" : "Join")
                        .font(.subheadline.weight(.semibold))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(Color.white.opacity(vm.isJoined(c) ? 0.55 : 0.85))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(Color.white.opacity(0.75), lineWidth: 1)
                        )
                        .foregroundStyle(vm.isJoined(c) ? Theme.textSecondary : Theme.textPrimary)
                }
            }

            HStack(spacing: 10) {
                Text("\(c.member_count) members")
                if c.is_private { Text("Private") }
                if c.is_nsfw { Text("Mature") }
            }
            .font(.caption2)
            .foregroundStyle(Theme.textSecondary)
        }
        .padding(18)
        .background(Theme.lightCard())
    }
}
