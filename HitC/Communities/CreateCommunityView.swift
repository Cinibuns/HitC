//
//  CreateCommunityView.swift
//  HitC
//
//  Created by Matt Symons on 3/2/2026.
//

import SwiftUI

struct CreateCommunityPayload {
    let name: String
    let slug: String
    let description: String?
    let isPrivate: Bool
    let isNsfw: Bool
}

struct CreateCommunityView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var slug = ""
    @State private var description = ""
    @State private var isPrivate = false
    @State private var isNsfw = false

    let onCreate: (CreateCommunityPayload) -> Void

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

    private var canCreate: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !slug.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LightCloudBackground()
                    .allowsHitTesting(false)

                ScrollView {
                    VStack(spacing: 14) {
                        headerCard
                        formCard
                        actionCard
                        Spacer(minLength: 24)
                    }
                    .padding(.horizontal)
                    .padding(.top, 14)
                }
            }
            .navigationTitle("")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { dismiss() }
                        .foregroundStyle(Theme.textPrimary)
                }
            }
        }
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundStyle(cloudsGradient)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Create Community")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(Theme.textPrimary)
                    Text("Make a little home in the clouds ☁️")
                        .font(.subheadline)
                        .foregroundStyle(Theme.textSecondary)
                }

                Spacer()
            }
        }
        .padding(20)
        .background(Theme.lightCard())
    }

    private var formCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            labeledField(title: "Name") {
                TextField("Community name", text: $name)
                    .textInputAutocapitalization(.words)
            }

            labeledField(title: "Slug") {
                TextField("my-community", text: $slug)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            }

            labeledField(title: "Description (optional)") {
                TextField("A short description…", text: $description, axis: .vertical)
                    .lineLimit(2...4)
            }

            Divider().opacity(0.25)

            Toggle("Private (members only)", isOn: $isPrivate)
                .tint(Color(red: 0.84, green: 0.10, blue: 0.62))
                .foregroundStyle(Theme.textPrimary)

            Toggle("Mature (NSFW)", isOn: $isNsfw)
                .tint(Color(red: 0.84, green: 0.10, blue: 0.62))
                .foregroundStyle(Theme.textPrimary)
        }
        .padding(20)
        .background(Theme.lightCard())
    }

    private var actionCard: some View {
        VStack(spacing: 10) {
            Button {
                let cleanedSlug = slug
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .lowercased()
                    .replacingOccurrences(of: " ", with: "-")

                onCreate(
                    CreateCommunityPayload(
                        name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                        slug: cleanedSlug,
                        description: description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : description,
                        isPrivate: isPrivate,
                        isNsfw: isNsfw
                    )
                )
            } label: {
                HStack(spacing: 10) {
                    Text("Create community")
                    Image(systemName: "arrow.right")
                }
            }
            .buttonStyle(NeonRingPrimaryButtonStyle())
            .disabled(!canCreate)

            Text("Tip: Keep slugs short — they become your community link.")
                .font(.caption)
                .foregroundStyle(Theme.textSecondary)
        }
        .padding(20)
        .background(Theme.lightCard())
    }

    private func labeledField<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.textPrimary)

            HStack(spacing: 10) {
                content()
                    .foregroundStyle(Theme.textPrimary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
            .background(Color.white.opacity(0.85))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.white.opacity(0.70), lineWidth: 1)
            )
        }
    }
}
