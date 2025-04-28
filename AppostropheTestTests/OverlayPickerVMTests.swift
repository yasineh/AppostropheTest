//  Created by Yasin Ehsani
//

import XCTest

@testable import AppostropheTest

@MainActor
final class OverlayPickerViewModelTests: XCTestCase {

    func testInitialState() {
        let vm = OverlayPickerViewModel()
        XCTAssertTrue(
            vm.overlays.isEmpty,
            "Expected no overlays to be loaded initially"
        )
        XCTAssertFalse(vm.isLoading, "Expected not to be loading initially")
        XCTAssertNil(vm.error, "Expected no error initially")
    }

    func testLoadOverlaysSuccess() async {
        let vm = OverlayPickerViewModel()
        await vm.load()

        XCTAssertFalse(vm.isLoading, "Expected not to be loading")
        XCTAssertNil(vm.error, "Expected no error")
        XCTAssertFalse(vm.overlays.isEmpty, "Expected overlays to be loaded")
    }
}
