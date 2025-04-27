//  Created by Yasin Ehsani
//

import Kingfisher
import SwiftUI

public struct RemoteImageLoader {
    public static func load(url: URL, completion: @escaping (UIImage?) -> Void)
    {
        let options: KingfisherOptionsInfo = [
            .retryStrategy(
                DelayRetryStrategy(maxRetryCount: 2, retryInterval: .seconds(3))
            )
        ]
        KingfisherManager.shared.retrieveImage(with: url, options: options) {
            result in
            switch result {
            case .success(let value):
                completion(value.image)
            case .failure(let error):
                print("[RemoteImageLoader] Failed to load:", error)
                completion(nil)
            }
        }
    }
}
