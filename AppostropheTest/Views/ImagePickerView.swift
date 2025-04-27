//
//  Created by Yasin Ehsani on 2025-04-27.
//

import PhotosUI
import SwiftUI

struct ImagePickerView: UIViewControllerRepresentable {
    @Binding var showPicker: Bool
    @Binding var imagesData: [Data]

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.selectionLimit = 5

        config.filter = .images

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(
        _ uiView: PHPickerViewController,
        context: Context
    ) {}

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePickerView

        init(parent: ImagePickerView) {
            self.parent = parent
        }

        func picker(
            _ picker: PHPickerViewController,
            didFinishPicking results: [PHPickerResult]
        ) {
            parent.showPicker = false

            guard !results.isEmpty else { return }
            parent.imagesData.removeAll()

            for result in results {
                let itemProvider = result.itemProvider

                if itemProvider.canLoadObject(ofClass: UIImage.self) {
                    itemProvider.loadObject(ofClass: UIImage.self) {
                        image,
                        error in
                        if let error = error {
                            print(
                                "[ImagePicker] Error loading image: \(error.localizedDescription)"
                            )
                            return
                        }

                        guard let uiImage = image as? UIImage else { return }

                        DispatchQueue.main.async {
                            if let data = uiImage.jpegData(
                                compressionQuality: 0.8
                            ) {
                                self.parent.imagesData.append(data)
                            }
                        }
                    }
                }
            }
        }
    }
}
