//  Created by Yasin Ehsani
//

import SwiftUI

@MainActor
class CanvasViewModel: NSObject,ObservableObject {
    
    @Published var stack: [StackItem] = []
    @Published var showImagePicker: Bool = false
    @Published var imagesData: [Data] = []
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    @Published var currentSelectedItem: StackItem?
    @Published var showDeleteAlert: Bool = false
    @Published var selectedItemID: String? = nil
    
    func addImageToStack(image: UIImage) {
        let originalSize = image.size
        let maxSide: CGFloat = 150
        let aspectRatio = originalSize.width / originalSize.height

        let displaySize = aspectRatio > 1
            ? CGSize(width: maxSide, height: maxSide / aspectRatio)
            : CGSize(width: maxSide * aspectRatio, height: maxSide)

        let imageView = Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: displaySize.width, height: displaySize.height)

        let newItem = StackItem(view: AnyView(imageView), frameSize: displaySize)
        stack.append(newItem)
        selectedItemID = newItem.id
    }
    
    
    func saveCanvasImage(view: some View, size: CGSize) {
        let image = view.snapshot(size: size)
        writeToAlbum(image: image)
    }
    
    func writeToAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompletion(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc func saveCompletion(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer){
        if let error  = error{
            showResult(message: error.localizedDescription, isError: true)
        } else {
            showResult(message: "Image saved successfully!")

        }
    }
    
    func safeArea() -> UIEdgeInsets {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first(where: \.isKeyWindow)?
            .safeAreaInsets ?? .zero
    }
    
    private func showResult(message: String, isError: Bool = false) {
        self.errorMessage = message
        self.showError = true
    }
    
}


