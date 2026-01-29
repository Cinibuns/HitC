//
//  BlurredNsfwImageView.swift
//  HitC
//
//  Created by Matt Symons on 29/1/2026.
//

import SwiftUI

struct BlurredNsfwImageView: View {
    let image: Image
    let isNsfw: Bool
    let blurEnabled: Bool

    @State private var isRevealed = false

    private var shouldBlur: Bool {
        isNsfw && blurEnabled && !isRevealed
    }

    var body: some View {
        ZStack {
            image
                .resizable()
                .scaledToFill()
                .blur(radius: shouldBlur ? 22 : 0)
                .animation(.easeOut(duration: 0.25), value: shouldBlur)

            if shouldBlur {
                // Dark scrim
                Rectangle()
                    .fill(.black.opacity(0.35))

                VStack(spacing: 8) {
                    Image(systemName: "eye.slash")
                        .font(.title2)

                    Text("NSFW content")
                        .font(.subheadline.weight(.semibold))

                    Text("Tap to view")
                        .font(.caption)
                        .opacity(0.85)
                }
                .foregroundStyle(.white)
                .padding(16)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .contentShape(Rectangle())
        .onTapGesture {
            if shouldBlur {
                withAnimation {
                    isRevealed = true
                }
            }
        }
    }
}
