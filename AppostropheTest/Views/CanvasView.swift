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

