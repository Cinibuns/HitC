//
//  PostRowView.swift
//  HitC
//
//  Created by Matt Symons on 29/1/2026.
//

import SwiftUI

struct PostRowView: View {
    @EnvironmentObject var appState: AppState

    let post: Post
    let displayName: String
    let liked: Bool
    let isExpanded: Bool

    let onToggleExpand: () -> Void
    let onToggleLike: () -> Void
    let onCommentPosted: () -> Void
    let onImageTapped: (URL) -> Void

    @State private var isNsfwRevealed = false

    private var blurEnabled: Bool { appState.profile?.blurNsfw ?? true }
    private var shouldBlur: Bool { post.isNsfw && blurEnabled && !isNsfwRevealed }

    private let imageCorner: CGFloat = 18
    private let glowSpace: CGFloat = 18

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

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .center, spacing: 10) {

                    // ✅ Placeholder avatar
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.70))
                            .frame(width: 36, height: 36)
                            .overlay(Circle().stroke(Color.white.opacity(0.70), lineWidth: 1))

                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(cloudsGradient)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(displayName)
                            .font(.headline)
                            .foregroundStyle(Theme.textPrimary)

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
                            Capsule().fill((post.isNsfw ? Color.pink : Color.green).opacity(0.18))
                        )
                        .overlay(Capsule().stroke(Color.white.opacity(0.70), lineWidth: 1))
                        .foregroundStyle(Theme.textPrimary)
                }

                Text(isExpanded ? "Tap to hide thread" : "💬 \(post.commentCount)  •  Tap to view thread")
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)

                Button(action: onToggleLike) {
                    HStack(spacing: 6) {
                        Image(systemName: liked ? "heart.fill" : "heart")
                        Text(liked ? "Liked" : "Like")
                    }
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Theme.textPrimary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 9)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color.white.opacity(0.70))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(Color.white.opacity(0.70), lineWidth: 1)
                            )
                    )
                }
                .buttonStyle(.plain)
            }
            .contentShape(Rectangle())
            .onTapGesture { onToggleExpand() }

            if let urlString = post.imageUrl, let url = URL(string: urlString) {
                ZStack {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable().scaledToFill()
                        default:
                            Rectangle().fill(Color.black.opacity(0.04))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .aspectRatio(4.0/3.0, contentMode: .fit)
                    .blur(radius: shouldBlur ? 16 : 0)
                    .compositingGroup()
                    .clipShape(RoundedRectangle(cornerRadius: imageCorner, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: imageCorner, style: .continuous)
                            .stroke(Color.white.opacity(0.70), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 6)

                    if shouldBlur {
                        RoundedRectangle(cornerRadius: imageCorner, style: .continuous)
                            .fill(Color.black.opacity(0.25))

                        VStack(spacing: 8) {
                            Image(systemName: "eye.slash")
                                .font(.title2)
                            Text("NSFW content")
                                .font(.subheadline.weight(.semibold))
                            Text("Tap to view")
                                .font(.caption)
                                .opacity(0.9)
                        }
                        .foregroundStyle(.white)
                        .padding(14)
                        .background(
                            .ultraThinMaterial,
                            in: RoundedRectangle(cornerRadius: 14, style: .continuous)
                        )
                    }
                }
                .overlay {
                    if shouldBlur {
                        GeometryReader { proxy in
                            let w = proxy.size.width
                            let h = proxy.size.height

                            RainbowPerimeterRing(cornerRadius: imageCorner, lineWidth: 2)
                                .frame(width: w, height: h)
                                .position(x: w / 2, y: h / 2)
                                .allowsHitTesting(false)

                            RainbowOuterGlow(cornerRadius: imageCorner, lineWidth: 2, glowSpace: glowSpace)
                                .frame(width: w + glowSpace * 2, height: h + glowSpace * 2)
                                .position(x: w / 2, y: h / 2)
                                .allowsHitTesting(false)
                        }
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    if shouldBlur {
                        withAnimation(.easeOut(duration: 0.20)) { isNsfwRevealed = true }
                    } else {
                        onImageTapped(url)
                    }
                }
            }

            if isExpanded {
                InlineCommentsView(
                    postId: post.id,
                    refreshKey: 0,
                    onPosted: onCommentPosted
                )
                .padding(.top, 4)
            }
        }
        .padding(16)
        .background(Theme.lightCard())
        .onChange(of: post.id) { _, _ in
            isNsfwRevealed = false
        }
    }
}

// keep your existing RainbowPerimeterRing + RainbowOuterGlow exactly as you already have
private struct RainbowPerimeterRing: View { /* unchanged */
    let cornerRadius: CGFloat
    let lineWidth: CGFloat
    @State private var angle: Double = 0
    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .strokeBorder(AngularGradient(
                gradient: Gradient(colors: [.red, .orange, .yellow, .green, .cyan, .blue, .purple, .pink, .red]),
                center: .center,
                angle: .degrees(angle)
            ), lineWidth: lineWidth)
            .shadow(color: Color.pink.opacity(0.75), radius: 18)
            .shadow(color: Color.cyan.opacity(0.60), radius: 22)
            .shadow(color: Color.purple.opacity(0.50), radius: 28)
            .drawingGroup()
            .onAppear {
                angle = 0
                withAnimation(.linear(duration: 5).repeatForever(autoreverses: false)) { angle = 360 }
            }
    }
}

private struct RainbowOuterGlow: View { /* unchanged */
    let cornerRadius: CGFloat
    let lineWidth: CGFloat
    let glowSpace: CGFloat
    @State private var angle: Double = 0

    var body: some View {
        ZStack {
            glowStroke(width: lineWidth + 12, blur: 14, opacity: 0.70)
            glowStroke(width: lineWidth + 6,  blur: 8,  opacity: 0.55)
        }
        .blendMode(.screen)
        .mask(
            RadialGradient(
                colors: [.white, .white.opacity(0.85), .white.opacity(0.0)],
                center: .center,
                startRadius: 6,
                endRadius: glowSpace * 1.15
            )
        )
        .drawingGroup()
        .onAppear {
            angle = 0
            withAnimation(.linear(duration: 5).repeatForever(autoreverses: false)) { angle = 360 }
        }
    }

    private func glowStroke(width: CGFloat, blur: CGFloat, opacity: Double) -> some View {
        RoundedRectangle(cornerRadius: cornerRadius + glowSpace, style: .continuous)
            .stroke(
                AngularGradient(
                    gradient: Gradient(colors: [.red, .orange, .yellow, .green, .cyan, .blue, .purple, .pink, .red]),
                    center: .center,
                    angle: .degrees(angle)
                ),
                lineWidth: width
            )
            .blur(radius: blur)
            .opacity(opacity)
    }
}

