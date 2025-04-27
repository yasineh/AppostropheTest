//  Created by Yasin Ehsani
//

import SwiftUI

struct CanvasItemView<Content: View>: View {
    var content: Content
    @Binding var stackItem: StackItem
    var moveFront: () -> Void
    var onDelete: (() -> Void)
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
            .overlay(
                ZStack {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.blue.opacity(0.4), lineWidth: 8)
                            .blur(radius: 8)
                            .offset(x: 0, y: 0)
                            .foregroundColor(.blue)
                            .transition(.opacity)

                        RoundedRectangle(cornerRadius: 8)
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.blue, Color.purple,
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                            .shadow(color: Color.blue.opacity(0.7), radius: 10)
                    }
                }
                .animation(.easeInOut(duration: 0.3), value: isSelected)
            )
            .rotationEffect(stackItem.rotation)
            .scaleEffect(max(stackItem.scale, 0.4) * hapticScale)
            .offset(stackItem.offset)
            .onAppear {
                if isSelected {
                    withAnimation(
                        .easeInOut(duration: 1).repeatForever(
                            autoreverses: true
                        )
                    ) {
                        pulsateScale = 1.05
                    }
                }
            }
            .onChange(of: isSelected) { _, newValue in
                if newValue {
                    withAnimation(
                        .easeInOut(duration: 1).repeatForever(
                            autoreverses: true
                        )
                    ) {
                        pulsateScale = 1.05
                    }
                } else {
                    pulsateScale = 1.0
                }
            }
            // MARK: Tap to select
            .highPriorityGesture(
                TapGesture().onEnded {
                    canvasModel.selectedItemID = stackItem.id
                }
            )
            // MARK: Double tap to delete / Hold to bring to front
            .gesture(
                TapGesture(count: 2)
                    .onEnded { onDelete() }
                    .simultaneously(
                        with: LongPressGesture(minimumDuration: 0.3)
                            .onEnded({ _ in
                                UIImpactFeedbackGenerator(style: .medium)
                                    .impactOccurred()
                                withAnimation(.easeInOut) {
                                    hapticScale = 1.2
                                }
                                withAnimation(.easeInOut.delay(0.1)) {
                                    hapticScale = 1
                                }
                                moveFront()
                            })
                    )
            )
            // MARK: Drag
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if canvasModel.selectedItemID != stackItem.id {
                            canvasModel.selectedItemID = stackItem.id
                        }
                        let proposed = CGSize(
                            width: stackItem.lastOffset.width
                                + value.translation.width,
                            height: stackItem.lastOffset.height
                                + value.translation.height
                        )
                        let itemSize = CGSize(
                            width: stackItem.frameSize.width
                                * max(stackItem.scale, 0.4),
                            height: stackItem.frameSize.height
                                * max(stackItem.scale, 0.4)
                        )
                        let snapped = canvasModel.snappedOffset(
                            for: proposed,
                            of: stackItem,
                            itemSize: itemSize
                        )
                        stackItem.offset = snapped
                    }
                    .onEnded { _ in
                        stackItem.lastOffset = stackItem.offset
                        canvasModel.clearGuidelines()
                    }
            )
            // MARK: Scale/Rotate
            .gesture(
                MagnificationGesture()
                    .onChanged({ value in
                        if canvasModel.selectedItemID != stackItem.id {
                            canvasModel.selectedItemID = stackItem.id
                        }
                        stackItem.scale = stackItem.lastScale + (value - 1)
                    }).onEnded({ value in
                        stackItem.lastScale = stackItem.scale
                    })
                    .simultaneously(
                        with:
                            RotationGesture()
                            .onChanged({ value in
                                stackItem.rotation =
                                    stackItem.lastRotation + value
                            }).onEnded({ value in
                                stackItem.lastRotation = stackItem.rotation
                            })
                    )
            )

    }
}
