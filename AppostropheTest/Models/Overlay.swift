//  Created by Yasin Ehsani
//

import Foundation

public struct Overlay: Identifiable, Decodable {
    public let id: String
    public let name: String
    public let url: URL

    enum CodingKeys: String, CodingKey {
        case id
        case overlay_name
        case source_url
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let overlayId = try container.decode(Int.self, forKey: .id)
        id = String(overlayId)
        name =
            (try? container.decode(String.self, forKey: .overlay_name))
            ?? "Overlay"
        let urlString = try container.decode(String.self, forKey: .source_url)
        guard let url = URL(string: urlString) else {
            throw DecodingError.dataCorrupted(
                .init(
                    codingPath: [CodingKeys.source_url],
                    debugDescription: "Invalid source_url"
                )
            )
        }
        self.url = url
    }
}
