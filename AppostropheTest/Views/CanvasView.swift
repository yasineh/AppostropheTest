//  Created by Yasin Ehsani
//

import SwiftUI

struct CanvasView: View {
    var height: CGFloat = 250
    @EnvironmentObject var canvasModel: CanvasViewModel

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            ZStack {
                Color.white.contentShape(Rectangle())
                    .onTapGesture {
                        canvasModel.selectedItemID = nil
                    }

                ForEach(canvasModel.snappLines) { snapp in
                    if snapp.orientation == .vertical {
                        Rectangle()
                            .fill(Color.yellow)
                            .frame(width: 1, height: snapp.end - snapp.start)
                            .offset(
                                x: snapp.position,
                                y: (snapp.start + snapp.end) / 2
                            )
                            .opacity(canvasModel.snappLines.isEmpty ? 0 : 1)
                            .animation(
                                .easeInOut(duration: 0.2),
                                value: canvasModel.snappLines
                            )
                    } else {
                        Rectangle()
                            .fill(Color.yellow)
                            .frame(width: snapp.end - snapp.start, height: 1)
                            .offset(
                                x: (snapp.start + snapp.end) / 2,
                                y: snapp.position
                            )
                            .opacity(canvasModel.snappLines.isEmpty ? 0 : 1)
                            .animation(
                                .easeInOut(duration: 0.2),
                                value: canvasModel.snappLines
                            )
                    }
                }

                ForEach($canvasModel.stack) { $stackItem in
                    CanvasItemView(
                        stackItem: $stackItem,
                        isSelected: canvasModel.selectedItemID == stackItem.id
                    ) {
                        stackItem.view
                    } moveFront: {
                        moveViewToFront(stackItem: stackItem)
                    } onDelete: {
                        canvasModel.currentSelectedItem = stackItem
                        canvasModel.showDeleteAlert.toggle()
                    }
                }
            }.frame(width: size.width, height: size.height)
                .onAppear { canvasModel.canvasSize = size }
                .onChange(of: size) { _, newSize in
                    canvasModel.canvasSize = newSize
                }
        }.frame(height: height)
            .clipped()
            .alert(
                "Do you want to remove this item?",
                isPresented: $canvasModel.showDeleteAlert
            ) {
                Button(role: .destructive) {
                    if let item = canvasModel.currentSelectedItem {
                        let index = getIndex(stackItem: item)
                        canvasModel.stack.remove(at: index)
                    }

                } label: {
                    Text("Delete")
                }
            }
    }

    private func getIndex(stackItem: StackItem) -> Int {
        return canvasModel.stack.firstIndex { item in
            return item.id == stackItem.id
        } ?? 0
    }

    private func moveViewToFront(stackItem: StackItem) {
        let currentIndex = getIndex(stackItem: stackItem)
        let lastIndex = canvasModel.stack.count - 1
        canvasModel.stack.insert(
            canvasModel.stack.remove(at: currentIndex),
            at: lastIndex
        )
    }

}
