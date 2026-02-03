//
//  AnimatedRainbowBorder.swift
//  HitC
//
//  Created by Matt Symons on 29/1/2026.
//

import SwiftUI

struct AnimatedRainbowBorder: View {
    var cornerRadius: CGFloat = 18
    var lineWidth: CGFloat = 2

    @State private var phase: CGFloat = 0

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .stroke(
                AngularGradient(
                    gradient: Gradient(colors: [
                        .red, .orange, .yellow, .green,
                        .blue, .purple, .pink, .red
                    ]),
                    center: .center,
                    angle: .degrees(phase)
                ),
                lineWidth: lineWidth
            )
            .blur(radius: 0.3) // subtle glow softness
            .onAppear {
                withAnimation(.linear(duration: 6).repeatForever(autoreverses: false)) {
                    phase = 360
                }
            }
    }
}
