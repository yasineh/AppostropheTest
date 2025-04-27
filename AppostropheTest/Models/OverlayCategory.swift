//  Created by Yasin Ehsani
//

import Foundation

public struct OverlayCategory: Decodable {
    public let title: String
    public let id: Int
    public let items: [Overlay]
}
