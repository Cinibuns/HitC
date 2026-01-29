//
//  RainbowDotsView.swift
//  HitC
//
//  Created by Matt Symons on 29/1/2026.
//

import SwiftUI

struct RainbowDotsView: View {
    private let colors: [Color] = [
        Color(red: 0.89, green: 0.01, blue: 0.01), // red
        Color(red: 1.00, green: 0.55, blue: 0.00), // orange
        Color(red: 1.00, green: 0.93, blue: 0.00), // yellow
        Color(red: 0.00, green: 0.50, blue: 0.15), // green
        Color(red: 0.00, green: 0.30, blue: 1.00), // blue
        Color(red: 0.46, green: 0.03, blue: 0.53)  // purple
    ]

    var body: some View {
        HStack(spacing: 8) {
            ForEach(Array(colors.enumerated()), id: \.offset) { _, c in
                Circle()
                    .fill(c)
                    .frame(width: 10, height: 10)
                    .shadow(color: c.opacity(0.35), radius: 8, x: 0, y: 0)
            }
        }
    }
}
