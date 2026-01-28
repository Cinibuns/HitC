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
    @State private var isLoading = false
    @State private var errorText: String?

    var body: some View {
        NavigationView {
            Group {
                if isLoading {
                    ProgressView("Loading feed…")
                } else if let errorText {
                    VStack(spacing: 12) {
                        Text("Couldn’t load feed.")
                        Text(errorText).foregroundStyle(.red).multilineTextAlignment(.center)
                        Button("Retry") { Task { await load() } }
                    }
                    .padding()
                } else {
                    List(posts) { post in
                        VStack(alignment: .leading, spacing: 6) {
                            Text("NSFW: \(post.isNsfw ? "Yes" : "No")")
                            Text("Author: \(post.authorId.uuidString)").font(.caption2)
                        }
                    }
                }
            }
            .navigationTitle("Home")
            .toolbar { Button("Refresh") { Task { await load() } } }
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
            posts = try await PostService.fetchFeed()
        } catch {
            errorText = error.localizedDescription
        }
    }
}

