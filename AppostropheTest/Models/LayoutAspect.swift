//  Created by Yasin Ehsani
//

import SwiftUI

public enum LayoutAspect: String, CaseIterable, Identifiable {
    case squareLayout = "1:1"
    case portraitLayout = "4:5"
    case landscapeLayout = "1.91:1"
    case storyLayout = "9:16"

    public var id: String { rawValue }

    public var ratio: (w: CGFloat, h: CGFloat) {
        switch self {
        case .squareLayout: return (1, 1)
        case .portraitLayout: return (4, 5)
        case .landscapeLayout: return (1.91, 1)
        case .storyLayout: return (9, 16)
        }
    }

    public var label: String {
        switch self {
        case .squareLayout: return "Square"
        case .portraitLayout: return "Portrait"
        case .landscapeLayout: return "Landscape"
        case .storyLayout: return "Story"
        }
    }
}
