//
//  Created by Yasin Ehsani
//

import XCTest

@testable import AppostropheTest

@MainActor
final class OverlayServiceTests: XCTestCase {

    func testFetchOverlaysReturnsCached() async throws {
        let service = OverlayService.shared
        let overlaysFirst = try await service.fetchOverlays(forceRefresh: true)
        let overlaysCached = try await service.fetchOverlays()

        XCTAssertEqual(
            overlaysFirst.count,
            overlaysCached.count,
            "Expected to be same"
        )
    }

    func testForceRefreshFetchesAgain() async throws {
        let service = OverlayService.shared
        let overlaysFirst = try await service.fetchOverlays(forceRefresh: true)
        let overlaysForceRefreshed = try await service.fetchOverlays(
            forceRefresh: true
        )

        XCTAssertEqual(
            overlaysFirst.count,
            overlaysForceRefreshed.count,
            "Expected to be same"
        )
    }
}
