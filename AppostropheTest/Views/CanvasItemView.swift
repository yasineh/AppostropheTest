//  Created by Yasin Ehsani
//

import SwiftUI

struct CanvasItemView<Content: View>: View {
    var content: Content
    @Binding var stackItem: StackItem
    var moveFront: () -> Void
    var onDelete: () -> Void
    let isSelected: Bool

    init(
        stackItem: Binding<StackItem>,
        isSelected: Bool,
        @ViewBuilder content: @escaping () -> Content,
        moveFront: @escaping () -> Void,
        onDelete: @escaping () -> Void
    ) {
        self.content = content()
        self._stackItem = stackItem
        self.moveFront = moveFront
        self.onDelete = onDelete
        self.isSelected = isSelected
    }

    @EnvironmentObject private var canvasModel: CanvasViewModel
    @State private var hapticScale: CGFloat = 1
    @State private var pulsateScale: CGFloat = 1.0

    var body: some View {
        content
            .overlay(selectionOverlay)
            .rotationEffect(stackItem.rotation)
            .scaleEffect(max(stackItem.scale, 0.4) * hapticScale)
            .offset(stackItem.offset)
            .onAppear { updatePulsateAnimation() }
            .onChange(of: isSelected) { _, _ in updatePulsateAnimation() }
            .highPriorityGesture(tapToSelectGesture)
            .gesture(doubleTapOrHoldGesture)
            .gesture(dragGesture)
            .gesture(scaleAndRotateGesture)
    }

    // MARK: - Selection Overlay

    private var selectionOverlay: some View {
        ZStack {
            if isSelected {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.blue.opacity(0.4), lineWidth: 8)
                    .blur(radius: 8)

                RoundedRectangle(cornerRadius: 8)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.blue, Color.purple]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
                    .shadow(color: Color.blue.opacity(0.7), radius: 10)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: isSelected)
    }

    // MARK: - Gestures

    private var tapToSelectGesture: some Gesture {
        TapGesture()
            .onEnded {
                canvasModel.selectedItemID = stackItem.id
            }
    }

    private var doubleTapOrHoldGesture: some Gesture {
        TapGesture(count: 2)
            .onEnded {
                onDelete()
            }
            .simultaneously(
                with: LongPressGesture(minimumDuration: 0.3)
                    .onEnded { _ in
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        withAnimation(.easeInOut) {
                            hapticScale = 1.2
                        }
                        withAnimation(.easeInOut.delay(0.1)) {
                            hapticScale = 1
                        }
                        moveFront()
                    }
            )
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                if canvasModel.selectedItemID != stackItem.id {
                    canvasModel.selectedItemID = stackItem.id
                }
                let proposed = CGSize(
                    width: stackItem.lastOffset.width + value.translation.width,
                    height: stackItem.lastOffset.height + value.translation.height
                )
                let itemSize = CGSize(
                    width: stackItem.frameSize.width * max(stackItem.scale, 0.4),
                    height: stackItem.frameSize.height * max(stackItem.scale, 0.4)
                )
                stackItem.offset = canvasModel.snappedOffset(
                    for: proposed,
                    of: stackItem,
                    itemSize: itemSize
                )
            }
            .onEnded { _ in
                stackItem.lastOffset = stackItem.offset
                canvasModel.clearGuidelines()
            }
    }

    private var scaleAndRotateGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                if canvasModel.selectedItemID != stackItem.id {
                    canvasModel.selectedItemID = stackItem.id
                }
                stackItem.scale = stackItem.lastScale + (value - 1)
            }
            .onEnded { _ in
                stackItem.lastScale = stackItem.scale
            }
            .simultaneously(
                with: RotationGesture()
                    .onChanged { value in
                        stackItem.rotation = stackItem.lastRotation + value
                    }
                    .onEnded { _ in
                        stackItem.lastRotation = stackItem.rotation
                    }
            )
    }

    private func updatePulsateAnimation() {
        if isSelected {
            withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                pulsateScale = 1.05
            }
        } else {
            pulsateScale = 1.0
        }
    }
}
