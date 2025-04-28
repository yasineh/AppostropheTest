//  Created by Yasin Ehsani
//

import SwiftUICore
import XCTest

@testable import AppostropheTest

@MainActor
final class CanvasViewModelTests: XCTestCase {

    var viewModel: CanvasViewModel!

    override func setUp() async throws {
        viewModel = CanvasViewModel()
        viewModel.canvasSize = CGSize(width: 300, height: 300)
    }

    override func tearDown() async throws {
        viewModel = nil
    }

    func testAddImageToStack() async throws {
        let testImage = UIImage(systemName: "star")!
        viewModel.addImageToStack(image: testImage)
        let testImage2 = UIImage(systemName: "arrow.triangle.2.circlepath")!
        viewModel.addImageToStack(image: testImage2)
        XCTAssertEqual(
            viewModel.stack.count,
            2,
            "Expected stack list to have 2 items"
        )
        XCTAssertNotNil(
            viewModel.selectedItemID,
            "Expected selectedItemID to not be nil"
        )
    }

    func testClearCanvas() async throws {
        let testImage = UIImage(systemName: "star")!
        viewModel.addImageToStack(image: testImage)
        let testImage2 = UIImage(systemName: "arrow.triangle.2.circlepath")!
        viewModel.addImageToStack(image: testImage2)

        viewModel.clearCanvas()
        XCTAssertTrue(
            viewModel.stack.isEmpty,
            "Expected stack list to be empty"
        )
        XCTAssertTrue(
            viewModel.snappLines.isEmpty,
            "Expected snapLine list to be empty"
        )
        XCTAssertNil(viewModel.selectedItemID, "Expected to be nil")
        XCTAssertNil(viewModel.currentSelectedItem, "Expected to be nil")
    }

    func testClearGuidelines() async throws {
        viewModel.snappLines = [
            SnappLine(orientation: .vertical, position: 10, start: 0, end: 100)
        ]
        XCTAssertEqual(
            viewModel.snappLines.count,
            1,
            "Expected snapLine list to have 1 item"
        )
        viewModel.clearGuidelines()
        XCTAssertTrue(
            viewModel.snappLines.isEmpty,
            "Expected snapLine list to be empty"
        )
    }

    func testSnapOffsetIfNoCanvasSize() async throws {
        viewModel.canvasSize = .zero
        let proposed = CGSize(width: 100, height: 100)

        let result = viewModel.snappedOffset(
            for: proposed,
            of: StackItem(view: AnyView(EmptyView())),
            itemSize: CGSize(width: 100, height: 100)
        )

        XCTAssertEqual(
            result,
            proposed,
            "Expected snap to original proposed offset"
        )
    }
}
