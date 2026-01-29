//
//  Theme.swift
//  HitC
//
//  Created by Matt Symons on 28/1/2026.
//

import SwiftUI

enum Theme {
    static let textPrimary = Color.black.opacity(0.92)
    static let textSecondary = Color.black.opacity(0.60)

    static func lightCard() -> some View {
        RoundedRectangle(cornerRadius: 28, style: .continuous)
            .fill(Color.white.opacity(0.72))
            .overlay(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(Color.white.opacity(0.70), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.10), radius: 30, x: 0, y: 18)
    }
}

struct LightCloudBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.white,
                    Color(red: 0.94, green: 0.98, blue: 1.00),
                    Color(red: 1.00, green: 0.95, blue: 0.96)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 1.00, green: 0.78, blue: 0.86),
                            Color(red: 0.80, green: 0.82, blue: 1.00),
                            Color(red: 0.73, green: 0.91, blue: 1.00),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .opacity(0.55)
                .blur(radius: 42)
                .offset(x: -140, y: -220)
                .scaleEffect(1.4)

            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 1.00, green: 0.84, blue: 0.72),
                            Color(red: 1.00, green: 0.74, blue: 0.82),
                            Color(red: 0.82, green: 0.78, blue: 1.00),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .opacity(0.45)
                .blur(radius: 46)
                .offset(x: 160, y: -120)
                .scaleEffect(1.5)

            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.73, green: 0.96, blue: 0.90),
                            Color(red: 0.74, green: 0.88, blue: 1.00),
                            Color(red: 1.00, green: 0.82, blue: 0.92),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .opacity(0.40)
                .blur(radius: 50)
                .offset(x: -160, y: 160)
                .scaleEffect(1.7)
        }
        .ignoresSafeArea()
    }
}

struct BubbleBackground: View {
    var isReply: Bool

    var body: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(Color.white.opacity(isReply ? 0.78 : 0.82))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.white.opacity(0.70), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.08), radius: 14, x: 0, y: 8)
    }
}

struct NeonRingPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.bold))
            .foregroundStyle(.white)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(
                            AngularGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 1.00, green: 0.22, blue: 0.55),
                                    Color(red: 1.00, green: 0.73, blue: 0.20),
                                    Color(red: 0.20, green: 0.85, blue: 0.60),
                                    Color(red: 0.16, green: 0.82, blue: 0.94),
                                    Color(red: 0.49, green: 0.26, blue: 0.93),
                                    Color(red: 1.00, green: 0.22, blue: 0.55)
                                ]),
                                center: .center
                            ),
                            lineWidth: 2
                        )

                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 1.00, green: 0.35, blue: 0.62),
                                    Color(red: 0.49, green: 0.36, blue: 1.00),
                                    Color(red: 0.23, green: 0.67, blue: 1.00)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .padding(2)
                        .opacity(configuration.isPressed ? 0.88 : 1.0)
                }
            )
            .shadow(color: Color.black.opacity(0.14), radius: 18, x: 0, y: 10)
            .scaleEffect(configuration.isPressed ? 0.99 : 1.0)
    }
}

struct SoftSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(Theme.textPrimary)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.white.opacity(0.70))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(Color.white.opacity(0.70), lineWidth: 1)
                    )
            )
            .shadow(color: Color.black.opacity(0.10), radius: 14, x: 0, y: 8)
            .scaleEffect(configuration.isPressed ? 0.99 : 1.0)
    }
}
