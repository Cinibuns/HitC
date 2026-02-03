//
//  CreatePostView.swift
//  HitC
//
//  Created by Matt Symons on 3/2/2026.
//

import SwiftUI

struct CreatePostPayload {
    let title: String?
    let body: String?
    let isNsfw: Bool
}

struct CreatePostView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var postBody = ""
    @State private var isNsfw = false

    @State private var errorText: String?
    @State private var isSubmitting = false

    @FocusState private var focusedField: Field?

    enum Field { case title, body }

    /// Return true if the post was created successfully (so we can dismiss)
    let onCreate: (CreatePostPayload) async -> Bool

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

    private var canPost: Bool {
        let t = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let b = postBody.trimmingCharacters(in: .whitespacesAndNewlines)
        return (!t.isEmpty || !b.isEmpty) && !isSubmitting
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LightCloudBackground()
                    .allowsHitTesting(false)

                ScrollView {
                    VStack(spacing: 14) {
                        headerCard
                        editorCard
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
                        .disabled(isSubmitting)
                }

                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") { focusedField = nil }
                }
            }
            .onAppear {
                // feels native: cursor ready immediately
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    focusedField = .title
                }
            }
        }
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                Image(systemName: "square.and.pencil")
                    .font(.title2)
                    .foregroundStyle(cloudsGradient)

                VStack(alignment: .leading, spacing: 2) {
                    Text("New Post")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(Theme.textPrimary)
                    Text("Say something nice ☁️")
                        .font(.subheadline)
                        .foregroundStyle(Theme.textSecondary)
                }

                Spacer()
            }
        }
        .padding(20)
        .background(Theme.lightCard())
    }

    private var editorCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            labeledField(title: "Title (optional)") {
                TextField("Give it a vibe…", text: $title)
                    .focused($focusedField, equals: .title)
                    .submitLabel(.next)
                    .onSubmit { focusedField = .body }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Body")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.textPrimary)

                TextField("Write your post…", text: $postBody, axis: .vertical)
                    .focused($focusedField, equals: .body)
                    .lineLimit(4...12)
                    .submitLabel(.done)
                    .onSubmit { focusedField = nil }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 14)
                    .background(Color.white.opacity(0.85))
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(Color.white.opacity(0.70), lineWidth: 1)
                    )
                    .foregroundStyle(Theme.textPrimary)
            }

            Divider().opacity(0.25)

            Toggle("Mature (NSFW)", isOn: $isNsfw)
                .tint(Color(red: 0.84, green: 0.10, blue: 0.62))
                .foregroundStyle(Theme.textPrimary)

            if let errorText {
                Text(errorText)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
        .padding(20)
        .background(Theme.lightCard())
    }

    private var actionCard: some View {
        VStack(spacing: 10) {
            Button {
                Task { await submit() }
            } label: {
                HStack(spacing: 10) {
                    Text(isSubmitting ? "Posting…" : "Post")
                    Image(systemName: "arrow.up.circle.fill")
                }
            }
            .buttonStyle(NeonRingPrimaryButtonStyle())
            .disabled(!canPost)

            Text("Tip: Joining a community controls who can see community posts.")
                .font(.caption)
                .foregroundStyle(Theme.textSecondary)
        }
        .padding(20)
        .background(Theme.lightCard())
    }

    private func submit() async {
        guard !isSubmitting else { return }
        errorText = nil
        focusedField = nil

        let t = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let b = postBody.trimmingCharacters(in: .whitespacesAndNewlines)

        if t.isEmpty && b.isEmpty {
            errorText = "Write something first 🙂"
            return
        }

        isSubmitting = true
        let ok = await onCreate(
            CreatePostPayload(
                title: t.isEmpty ? nil : t,
                body: b.isEmpty ? nil : b,
                isNsfw: isNsfw
            )
        )
        isSubmitting = false

        if ok {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            dismiss()
        } else {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        }
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
