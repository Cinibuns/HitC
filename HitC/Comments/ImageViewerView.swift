//
//  ImageViewerView.swift
//  HitC
//
//  Created by Matt Symons on 29/1/2026.
//

import SwiftUI

struct ImageViewerView: View {
    let url: URL
    @Environment(\.dismiss) private var dismiss

    @State private var scale: CGFloat = 1
    @State private var lastScale: CGFloat = 1

    @State private var pan: CGSize = .zero
    @State private var lastPan: CGSize = .zero

    @State private var dismissDragY: CGFloat = 0

    private let maxScale: CGFloat = 4
    private let dismissThreshold: CGFloat = 140

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.black
                .opacity(backgroundOpacity)
                .ignoresSafeArea()

            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .scaleEffect(scale)
                        .offset(x: pan.width, y: pan.height + dismissDragY)
                        .gesture(magnifyGesture)
                        .simultaneousGesture(combinedDragGesture)
                        .animation(.spring(response: 0.25, dampingFraction: 0.9), value: dismissDragY)
                        .animation(.spring(response: 0.25, dampingFraction: 0.9), value: scale)

                case .failure:
                    VStack(spacing: 10) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.title2)
                            .foregroundStyle(.white)
                        Text("Couldn’t load image")
                            .foregroundStyle(.white.opacity(0.8))
                    }

                default:
                    ProgressView().tint(.white)
                }
            }

            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .padding(12)
                    .background(Color.black.opacity(0.6))
                    .clipShape(Circle())
            }
            .padding(.top, 16)
            .padding(.trailing, 16)
        }
    }

    private var backgroundOpacity: Double {
        let t = min(max(dismissDragY / 250, 0), 1)
        return 1.0 - (0.4 * t)
    }

    private var magnifyGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                let newScale = lastScale * value
                scale = min(max(newScale, 1), maxScale)
            }
            .onEnded { _ in
                lastScale = scale
                if scale <= 1.01 {
                    scale = 1
                    lastScale = 1
                    pan = .zero
                    lastPan = .zero
                }
            }
    }

    private var combinedDragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                let dx = value.translation.width
                let dy = value.translation.height

                if scale > 1.01 {
                    if dy > 0, isNearTopEdge {
                        dismissDragY = dy
                    } else {
                        pan = CGSize(width: lastPan.width + dx, height: lastPan.height + dy)
                    }
                } else {
                    dismissDragY = max(0, dy)
                }
            }
            .onEnded { value in
                if dismissDragY > 0 {
                    if dismissDragY > dismissThreshold {
                        dismiss()
                    } else {
                        dismissDragY = 0
                    }
                    return
                }

                if scale > 1.01 {
                    lastPan = pan
                } else {
                    pan = .zero
                    lastPan = .zero
                }
            }
    }

    private var isNearTopEdge: Bool {
        pan.height > -40
    }
}
