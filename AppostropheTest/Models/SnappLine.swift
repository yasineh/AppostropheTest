//  Created by Yasin Ehsani

import SwiftUI

struct SnappLine: Identifiable, Hashable {
    enum Orientation { case vertical, horizontal }
    let id = UUID()
    let orientation: Orientation
    let position: CGFloat
    let start: CGFloat
    let end: CGFloat
}
