//
//  Theme.swift
//  HitC
//
//  Created by Matt Symons on 28/1/2026.
//

import SwiftUI

enum Theme {
    // Cloudy multi-gradient background
    static let appGradient = LinearGradient(
        colors: [
            Color(red: 0.52, green: 0.26, blue: 0.95), // purple
            Color(red: 0.22, green: 0.48, blue: 0.98), // blue
            Color(red: 1.00, green: 0.45, blue: 0.62), // pink
            Color(red: 1.00, green: 0.62, blue: 0.28)  // orange
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let surface = Color.white.opacity(0.10)
    static let surfaceBorder = Color.white.opacity(0.16)
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.75)

    static func card() -> some View {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
            .fill(Theme.surface)
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Theme.surfaceBorder, lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.18), radius: 14, x: 0, y: 10)
    }

    static func pill() -> some View {
        Capsule(style: .continuous)
            .fill(Color.white.opacity(0.14))
            .overlay(Capsule(style: .continuous).stroke(Color.white.opacity(0.18), lineWidth: 1))
    }
}

// MARK: - Background wrapper
struct CloudBackground: View {
    var body: some View {
        ZStack {
            Theme.appGradient

            // “cloud haze” layers (soft blobs)
            Circle()
                .fill(Color.white.opacity(0.14))
                .blur(radius: 30)
                .offset(x: -120, y: -220)
                .scaleEffect(1.4)

            Circle()
                .fill(Color.white.opacity(0.10))
                .blur(radius: 34)
                .offset(x: 140, y: -140)
                .scaleEffect(1.6)

            Circle()
                .fill(Color.white.opacity(0.10))
                .blur(radius: 36)
                .offset(x: -140, y: 120)
                .scaleEffect(1.8)

            Circle()
                .fill(Color.white.opacity(0.08))
                .blur(radius: 40)
                .offset(x: 120, y: 240)
                .scaleEffect(2.0)
        }
        .ignoresSafeArea()
    }
}

// MARK: - Buttons
struct GradientPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(.white)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(
                    colors: [
                        Color(red: 0.63, green: 0.28, blue: 1.00), // purple
                        Color(red: 0.25, green: 0.55, blue: 1.00), // blue
                        Color(red: 1.00, green: 0.45, blue: 0.62)  // pink
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .opacity(configuration.isPressed ? 0.85 : 1.0)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.white.opacity(0.18), lineWidth: 1)
            )
    }
}

struct SoftButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.white)
            .padding(.vertical, 10)
            .padding(.horizontal, 14)
            .background(Theme.pill().opacity(configuration.isPressed ? 0.8 : 1.0))
    }
}

// MARK: - Reply bubble background
struct BubbleBackground: View {
    var isReply: Bool
    var body: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(Color.white.opacity(isReply ? 0.10 : 0.12))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.white.opacity(0.16), lineWidth: 1)
            )
    }
}
