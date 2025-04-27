//  Created by Yasin Ehsani
//

import Foundation

public final class OverlayService {
    public static let shared = OverlayService()
    private init() {}
    private let endpoint = API.overlayEndpoint
    private var cache: [Overlay]?

    public func fetchOverlays(forceRefresh: Bool = false) async throws
        -> [Overlay]
    {
        if let cache = cache, !forceRefresh {
            return cache
        }

        let (data, _) = try await URLSession.shared.data(from: endpoint)
        let decoded = try JSONDecoder().decode(
            [OverlayCategory].self,
            from: data
        )
        let overlays = decoded.flatMap { $0.items }

        self.cache = overlays
        return overlays
    }
}
