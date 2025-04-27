//  Created by Yasin Ehsani
//

import SwiftUI

struct MainView: View {

    @StateObject private var canvasModel = CanvasViewModel()
    @State private var showLayoutSheet = false
    @State private var showOverlaySheet = false
    @State private var aspect: LayoutAspect = .squareLayout

    private let tabBarHeight: CGFloat = 80
    private var canvasSize: CGSize {
        let width = UIScreen.main.bounds.width - 32
        let height = width * aspect.ratio.h / aspect.ratio.w
        return CGSize(width: width, height: height)
    }
    private var dynamicBottomPadding: CGFloat {
        tabBarHeight + canvasModel.safeArea().bottom + 10
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer(minLength: 40)

                CanvasView(height: canvasSize.height)
                    .environmentObject(canvasModel)
                    .frame(width: canvasSize.width, height: canvasSize.height)
                    .padding(.horizontal, 16)

                Spacer()
            }
            .padding(.bottom, dynamicBottomPadding)

            VStack {
                Spacer()
                TabBar {
                    TabBarButton(icon: "square.grid.2x2", label: "Layout") {
                        showLayoutSheet = true
                    }
                    TabBarButton(icon: "photo.on.rectangle", label: "Photos") {
                        canvasModel.showImagePicker = true
                    }
                    TabBarButton(icon: "square.stack.3d.up", label: "Overlays")
                    {
                        showOverlaySheet = true
                    }
                    TabBarButton(icon: "square.and.arrow.down", label: "Save") {
                        saveCanvas()
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
        .alert(canvasModel.errorMessage, isPresented: $canvasModel.showError) {}

        .sheet(isPresented: $showLayoutSheet) {
            LayoutPicker(selected: $aspect)
        }
        .sheet(isPresented: $canvasModel.showImagePicker) {
            ImagePickerView(
                showPicker: $canvasModel.showImagePicker,
                imagesData: $canvasModel.imagesData
            )
            .onDisappear { handleSelectedImages() }
        }
        .sheet(isPresented: $showOverlaySheet) {
            OverlayPickerView { overlay in
                RemoteImageLoader.load(url: overlay.url) { loadedImage in
                    guard let image = loadedImage else {
                        print("[OverlayPicker] Failed to load overlay image")
                        return
                    }
                    canvasModel.addImageToStack(image: image)
                }
            }
        }
    }

    private func handleSelectedImages() {
        for imageData in canvasModel.imagesData {
            if let image = UIImage(data: imageData) {
                canvasModel.addImageToStack(image: image)
            }
        }
        canvasModel.imagesData.removeAll()
    }

    private func saveCanvas() {
        canvasModel.selectedItemID = nil
        canvasModel.currentSelectedItem = nil
        canvasModel.saveCanvasImage(
            view: CanvasView(height: canvasSize.height)
                .environmentObject(canvasModel),
            size: canvasSize
        )
    }
}

#Preview {
    MainView()
}
