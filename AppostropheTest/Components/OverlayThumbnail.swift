//  Created by Yasin Ehsani
//
import SwiftUI

struct OverlayThumbnail: View {
    let url: URL
    @State private var image: UIImage?
    @State private var loadFailed = false

    var body: some View {
        ZStack {
            if let img = image {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFit()
                    .frame(minHeight: 100)
            } else if loadFailed {
                Image(systemName: "exclamationmark.triangle.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.red)
                    .padding(20)
            } else {
                ProgressView()
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .frame(maxWidth: .infinity)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
        .clipped()
        .onAppear {
            if image == nil && !loadFailed {
                RemoteImageLoader.load(url: url) { loadedImage in
                    if let loaded = loadedImage {
                        self.image = loaded
                    } else {
                        self.loadFailed = true
                    }
                }
            }
        }
    }
}
