//  Created by Yasin Ehsani
//

import SwiftUI

@main
struct AppostropheTestApp: App {
    init() {
        AppConfig.configureImageLoading()
    }
    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }
}
