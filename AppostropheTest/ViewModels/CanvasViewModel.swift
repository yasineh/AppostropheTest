//  Created by Yasin Ehsani
//

import SwiftUI

@MainActor
class CanvasViewModel: NSObject, ObservableObject {
    @Published var stack: [StackItem] = []
    @Published var showImagePicker: Bool = false
    @Published var imagesData: [Data] = []
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    @Published var currentSelectedItem: StackItem?
    @Published var showDeleteAlert: Bool = false
    @Published var selectedItemID: String? = nil
    @Published var snappLines: [SnappLine] = []

    var canvasSize: CGSize = .zero
    private let snapThreshold: CGFloat = 10
    let defaultItemSide: CGFloat = 150
    private var hapticEngaged = false

    func addImageToStack(image: UIImage) {
        let originalSize = image.size
        let maxSide = defaultItemSide
        let aspectRatio = originalSize.width / originalSize.height

        let displaySize =
            aspectRatio > 1
            ? CGSize(width: maxSide, height: maxSide / aspectRatio)
            : CGSize(width: maxSide * aspectRatio, height: maxSide)

        let imageView = Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: displaySize.width, height: displaySize.height)

        let newItem = StackItem(
            view: AnyView(imageView),
            frameSize: displaySize
        )
        stack.append(newItem)
        selectedItemID = newItem.id
    }

    func snappedOffset(
        for proposed: CGSize,
        of item: StackItem,
        itemSize: CGSize
    ) -> CGSize {
        guard canvasSize != .zero else { return proposed }

        var result = proposed
        let halfW = itemSize.width / 2
        let halfH = itemSize.height / 2

        func edges(for center: CGSize, halfW: CGFloat, halfH: CGFloat) -> (
            l: CGFloat, r: CGFloat, t: CGFloat, b: CGFloat
        ) {
            (
                center.width - halfW, center.width + halfW,
                center.height - halfH, center.height + halfH
            )
        }

        var newLines: Set<SnappLine> = []

        let canvasHalfW = canvasSize.width / 2
        let canvasHalfH = canvasSize.height / 2

        let canvasEdges = (
            l: -canvasHalfW + halfW,
            r: canvasHalfW - halfW,
            t: -canvasHalfH + halfH,
            b: canvasHalfH - halfH
        )

        if abs(result.width - canvasEdges.l) < snapThreshold {
            result.width = canvasEdges.l
            insertLinesSafely(
                SnappLine(
                    orientation: .vertical,
                    position: canvasEdges.l,
                    start: -canvasHalfH,
                    end: canvasHalfH
                ),
                into: &newLines
            )
        }
        if abs(result.width - canvasEdges.r) < snapThreshold {
            result.width = canvasEdges.r
            insertLinesSafely(
                SnappLine(
                    orientation: .vertical,
                    position: canvasEdges.r,
                    start: -canvasHalfH,
                    end: canvasHalfH
                ),
                into: &newLines
            )
        }
        if abs(result.height - canvasEdges.t) < snapThreshold {
            result.height = canvasEdges.t
            insertLinesSafely(
                SnappLine(
                    orientation: .horizontal,
                    position: canvasEdges.t,
                    start: -canvasHalfW,
                    end: canvasHalfW
                ),
                into: &newLines
            )
        }
        if abs(result.height - canvasEdges.b) < snapThreshold {
            result.height = canvasEdges.b
            insertLinesSafely(
                SnappLine(
                    orientation: .horizontal,
                    position: canvasEdges.b,
                    start: -canvasHalfW,
                    end: canvasHalfW
                ),
                into: &newLines
            )
        }

        for peer in stack where peer.id != item.id {
            let peerWidth = peer.frameSize.width * max(peer.scale, 0.4)
            let peerHeight = peer.frameSize.height * max(peer.scale, 0.4)
            let peerHalfW = peerWidth / 2
            let peerHalfH = peerHeight / 2
            let peerEdges = edges(
                for: peer.offset,
                halfW: peerHalfW,
                halfH: peerHalfH
            )
            let myEdges = edges(for: result, halfW: halfW, halfH: halfH)

            if abs(myEdges.l - peerEdges.l) < snapThreshold {
                result.width = peerEdges.l + halfW
                let (startY, endY) = verticalSpan(
                    peerEdges: peerEdges,
                    alignedEdges: myEdges
                )
                insertLinesSafely(
                    SnappLine(
                        orientation: .vertical,
                        position: peerEdges.l,
                        start: startY,
                        end: endY
                    ),
                    into: &newLines
                )
            }

            if abs(myEdges.r - peerEdges.r) < snapThreshold {
                result.width = peerEdges.r - halfW
                let (startY, endY) = verticalSpan(
                    peerEdges: peerEdges,
                    alignedEdges: myEdges
                )
                insertLinesSafely(
                    SnappLine(
                        orientation: .vertical,
                        position: peerEdges.r,
                        start: startY,
                        end: endY
                    ),
                    into: &newLines
                )
            }

            if abs(myEdges.t - peerEdges.t) < snapThreshold {
                result.height = peerEdges.t + halfH
                let (startX, endX) = horizontalSpan(
                    peerEdges: peerEdges,
                    alignedEdges: myEdges
                )
                insertLinesSafely(
                    SnappLine(
                        orientation: .horizontal,
                        position: peerEdges.t,
                        start: startX,
                        end: endX
                    ),
                    into: &newLines
                )
            }

            if abs(myEdges.b - peerEdges.b) < snapThreshold {
                result.height = peerEdges.b - halfH
                let (startX, endX) = horizontalSpan(
                    peerEdges: peerEdges,
                    alignedEdges: myEdges
                )
                insertLinesSafely(
                    SnappLine(
                        orientation: .horizontal,
                        position: peerEdges.b,
                        start: startX,
                        end: endX
                    ),
                    into: &newLines
                )
            }

            if abs(myEdges.r - peerEdges.l) < snapThreshold {
                result.width = peerEdges.l - halfW
                let (startY, endY) = verticalSpan(
                    peerEdges: peerEdges,
                    alignedEdges: myEdges
                )
                insertLinesSafely(
                    SnappLine(
                        orientation: .vertical,
                        position: peerEdges.l,
                        start: startY,
                        end: endY
                    ),
                    into: &newLines
                )
            }

            if abs(myEdges.l - peerEdges.r) < snapThreshold {
                result.width = peerEdges.r + halfW
                let (startY, endY) = verticalSpan(
                    peerEdges: peerEdges,
                    alignedEdges: myEdges
                )
                insertLinesSafely(
                    SnappLine(
                        orientation: .vertical,
                        position: peerEdges.r,
                        start: startY,
                        end: endY
                    ),
                    into: &newLines
                )
            }

            if abs(myEdges.b - peerEdges.t) < snapThreshold {
                result.height = peerEdges.t - halfH
                let (startX, endX) = horizontalSpan(
                    peerEdges: peerEdges,
                    alignedEdges: myEdges
                )
                insertLinesSafely(
                    SnappLine(
                        orientation: .horizontal,
                        position: peerEdges.t,
                        start: startX,
                        end: endX
                    ),
                    into: &newLines
                )
            }

            if abs(myEdges.t - peerEdges.b) < snapThreshold {
                result.height = peerEdges.b + halfH
                let (startX, endX) = horizontalSpan(
                    peerEdges: peerEdges,
                    alignedEdges: myEdges
                )
                insertLinesSafely(
                    SnappLine(
                        orientation: .horizontal,
                        position: peerEdges.b,
                        start: startX,
                        end: endX
                    ),
                    into: &newLines
                )
            }
        }

        snappLines = Array(newLines)
        handleHaptic(newLines.count)
        return result
    }

    private func insertLinesSafely(
        _ line: SnappLine,
        into lines: inout Set<SnappLine>
    ) {
        if !lines.contains(where: {
            $0.orientation == line.orientation
                && abs($0.position - line.position) < 0.5
        }) {
            lines.insert(line)
        }
    }

    private func verticalSpan(
        peerEdges: (l: CGFloat, r: CGFloat, t: CGFloat, b: CGFloat),
        alignedEdges: (l: CGFloat, r: CGFloat, t: CGFloat, b: CGFloat)
    ) -> (CGFloat, CGFloat) {
        let minY = min(peerEdges.t, alignedEdges.t)
        let maxY = max(peerEdges.b, alignedEdges.b)
        return (minY, maxY)
    }

    private func horizontalSpan(
        peerEdges: (l: CGFloat, r: CGFloat, t: CGFloat, b: CGFloat),
        alignedEdges: (l: CGFloat, r: CGFloat, t: CGFloat, b: CGFloat)
    ) -> (CGFloat, CGFloat) {
        let minX = min(peerEdges.l, alignedEdges.l)
        let maxX = max(peerEdges.r, alignedEdges.r)
        return (minX, maxX)
    }

    private func handleHaptic(_ guideCount: Int) {
        if guideCount > 0, !hapticEngaged {
            UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
            hapticEngaged = true
        } else if guideCount == 0 {
            hapticEngaged = false
        }
    }

    func clearGuidelines() {
        snappLines.removeAll()
        hapticEngaged = false
    }

    func saveCanvasImage(view: some View, size: CGSize) {
        let image = view.snapshot(size: size)
        writeToAlbum(image: image)
    }

    func writeToAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(
            image,
            self,
            #selector(saveCompletion(_:didFinishSavingWithError:contextInfo:)),
            nil
        )
    }

    @objc func saveCompletion(
        _ image: UIImage,
        didFinishSavingWithError error: Error?,
        contextInfo: UnsafeRawPointer
    ) {
        if let error = error {
            showResult(message: error.localizedDescription, isError: true)
        } else {
            showResult(message: "Image saved successfully!")

        }
    }

    func safeArea() -> UIEdgeInsets {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first(where: \.isKeyWindow)?
            .safeAreaInsets ?? .zero
    }

    private func showResult(message: String, isError: Bool = false) {
        self.errorMessage = message
        self.showError = true
    }

}
