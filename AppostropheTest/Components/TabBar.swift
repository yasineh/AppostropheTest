//  Created by Yasin Ehsani
//

import SwiftUI

public struct TabBar<Content: View>: View {
    @ViewBuilder public let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        HStack(spacing: 32) {
            content
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 24)
        .background(Material.ultraThin)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .padding(.horizontal, 16)
        .padding(.bottom, safeBottomPadding)
        .shadow(color: .black.opacity(0.25), radius: 8, x: 0, y: 4)
    }

    private var safeBottomPadding: CGFloat {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }) else {
            return 10
        }
        return window.safeAreaInsets.bottom + 10
    }
}
