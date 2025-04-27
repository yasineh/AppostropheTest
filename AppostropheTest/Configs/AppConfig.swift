//  Created by Yasin Ehsani
//
import Foundation
import Kingfisher

public enum AppConfig {
    public static func configureImageLoading() {
        KingfisherManager.shared.downloader.downloadTimeout = 15
        print("[AppConfig] Kingfisher downloader timeout set.")
    }
}
