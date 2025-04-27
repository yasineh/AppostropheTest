//  Created by Yasin Ehsani
//

import SwiftUI

struct StackItem: Identifiable {
    var id = UUID().uuidString
    var view: AnyView
    var offset: CGSize = .zero
    var lastOffset: CGSize = .zero
    var scale: CGFloat = 1
    var lastScale: CGFloat = 1
    var rotation: Angle = .zero
    var lastRotation: Angle = .zero
    var frameSize: CGSize = .zero

}
