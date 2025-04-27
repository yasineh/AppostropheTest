//  Created by Yasin Ehsani
//

import SwiftUI

@MainActor
public final class OverlayPickerViewModel: ObservableObject {
    @Published public private(set) var overlays: [Overlay] = []
    @Published public var isLoading = false
    @Published public var error: String?

    public init() {}

    public func load() async {
        guard overlays.isEmpty else { return }
        isLoading = true
        do {
            overlays = try await OverlayService.shared.fetchOverlays()
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }
}
