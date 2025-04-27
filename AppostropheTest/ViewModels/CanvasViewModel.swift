//  Created by Yasin Ehsani
//

import SwiftUI

@MainActor
class CanvasViewModel: NSObject, ObservableObject {
    @Published var stack: [StackItem] = []
    @Published var showImagePicker = false
    @Published var imagesData: [Data] = []
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var currentSelectedItem: StackItem?
    @Published var showDeleteAlert = false
    @Published var selectedItemID: String?
    @Published var snappLines: [SnappLine] = []
    var canvasSize: CGSize = .zero
    private let snapThreshold: CGFloat = 10
    private let defaultItemSide: CGFloat = 150
    private var hapticEngaged = false

    // MARK: - Public funcs

    func addImageToStack(image: UIImage) {
        let displaySize = calculateDisplaySize(for: image)
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
        var newLines: Set<SnappLine> = []

        let halfW = itemSize.width / 2
        let halfH = itemSize.height / 2

        snapToCanvasEdges(
            &result,
            halfW: halfW,
            halfH: halfH,
            newLines: &newLines
        )
        snapToPeers(
            &result,
            item: item,
            halfW: halfW,
            halfH: halfH,
            newLines: &newLines
        )

        snappLines = Array(newLines)
        handleHaptic(newLines.count)

        return result
    }

    func clearGuidelines() {
        snappLines.removeAll()
        hapticEngaged = false
    }

    func clearCanvas() {
        stack.removeAll()
        snappLines.removeAll()
        selectedItemID = nil
        currentSelectedItem = nil
    }

    func saveCanvasImage(view: some View, size: CGSize) {
        let image = view.snapshot(size: size)
        writeToAlbum(image: image)
    }

    func safeArea() -> UIEdgeInsets {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first(where: \.isKeyWindow)?
            .safeAreaInsets ?? .zero
    }

    // MARK: - Private funcs

    private func calculateDisplaySize(for image: UIImage) -> CGSize {
        let aspectRatio = image.size.width / image.size.height
        let maxSide = defaultItemSide
        return aspectRatio > 1
            ? CGSize(width: maxSide, height: maxSide / aspectRatio)
            : CGSize(width: maxSide * aspectRatio, height: maxSide)
    }

    private func snapToCanvasEdges(
        _ result: inout CGSize,
        halfW: CGFloat,
        halfH: CGFloat,
        newLines: inout Set<SnappLine>
    ) {
        let canvasHalfW = canvasSize.width / 2
        let canvasHalfH = canvasSize.height / 2

        let edges = (
            l: -canvasHalfW + halfW,
            r: canvasHalfW - halfW,
            t: -canvasHalfH + halfH,
            b: canvasHalfH - halfH
        )

        checkAndSnap(
            &result.width,
            to: edges.l,
            isVertical: true,
            start: -canvasHalfH,
            end: canvasHalfH,
            newLines: &newLines
        )
        checkAndSnap(
            &result.width,
            to: edges.r,
            isVertical: true,
            start: -canvasHalfH,
            end: canvasHalfH,
            newLines: &newLines
        )
        checkAndSnap(
            &result.height,
            to: edges.t,
            isVertical: false,
            start: -canvasHalfW,
            end: canvasHalfW,
            newLines: &newLines
        )
        checkAndSnap(
            &result.height,
            to: edges.b,
            isVertical: false,
            start: -canvasHalfW,
            end: canvasHalfW,
            newLines: &newLines
        )
    }

    private func snapToPeers(
        _ result: inout CGSize,
        item: StackItem,
        halfW: CGFloat,
        halfH: CGFloat,
        newLines: inout Set<SnappLine>
    ) {
        for peer in stack where peer.id != item.id {
            let peerSize = CGSize(
                width: peer.frameSize.width * max(peer.scale, 0.4),
                height: peer.frameSize.height * max(peer.scale, 0.4)
            )
            let peerHalfW = peerSize.width / 2
            let peerHalfH = peerSize.height / 2
            let peerEdges = edges(
                for: peer.offset,
                halfW: peerHalfW,
                halfH: peerHalfH
            )
            let myEdges = edges(for: result, halfW: halfW, halfH: halfH)

            snapEdges(
                &result,
                myEdges: myEdges,
                peerEdges: peerEdges,
                halfW: halfW,
                halfH: halfH,
                newLines: &newLines
            )
        }
    }

    private func checkAndSnap(
        _ coordinate: inout CGFloat,
        to target: CGFloat,
        isVertical: Bool,
        start: CGFloat,
        end: CGFloat,
        newLines: inout Set<SnappLine>
    ) {
        if abs(coordinate - target) < snapThreshold {
            coordinate = target
            insertLinesSafely(
                SnappLine(
                    orientation: isVertical ? .vertical : .horizontal,
                    position: target,
                    start: start,
                    end: end
                ),
                into: &newLines
            )
        }
    }

    private func snapEdges(
        _ result: inout CGSize,
        myEdges: (l: CGFloat, r: CGFloat, t: CGFloat, b: CGFloat),
        peerEdges: (l: CGFloat, r: CGFloat, t: CGFloat, b: CGFloat),
        halfW: CGFloat,
        halfH: CGFloat,
        newLines: inout Set<SnappLine>
    ) {
        func trySnap(
            myEdge: CGFloat,
            peerEdge: CGFloat,
            adjust: (inout CGSize, CGFloat) -> Void,
            lineOrientation: SnappLine.Orientation,
            linePosition: CGFloat,
            start: CGFloat,
            end: CGFloat
        ) {
            if abs(myEdge - peerEdge) < snapThreshold {
                adjust(&result, peerEdge)
                insertLinesSafely(
                    SnappLine(
                        orientation: lineOrientation,
                        position: linePosition,
                        start: start,
                        end: end
                    ),
                    into: &newLines
                )
            }
        }

        trySnap(
            myEdge: myEdges.l,
            peerEdge: peerEdges.l,
            adjust: { $0.width = $1 + halfW },
            lineOrientation: .vertical,
            linePosition: peerEdges.l,
            start: min(peerEdges.t, myEdges.t),
            end: max(peerEdges.b, myEdges.b)
        )
        trySnap(
            myEdge: myEdges.r,
            peerEdge: peerEdges.r,
            adjust: { $0.width = $1 - halfW },
            lineOrientation: .vertical,
            linePosition: peerEdges.r,
            start: min(peerEdges.t, myEdges.t),
            end: max(peerEdges.b, myEdges.b)
        )
        trySnap(
            myEdge: myEdges.t,
            peerEdge: peerEdges.t,
            adjust: { $0.height = $1 + halfH },
            lineOrientation: .horizontal,
            linePosition: peerEdges.t,
            start: min(peerEdges.l, myEdges.l),
            end: max(peerEdges.r, myEdges.r)
        )
        trySnap(
            myEdge: myEdges.b,
            peerEdge: peerEdges.b,
            adjust: { $0.height = $1 - halfH },
            lineOrientation: .horizontal,
            linePosition: peerEdges.b,
            start: min(peerEdges.l, myEdges.l),
            end: max(peerEdges.r, myEdges.r)
        )
        trySnap(
            myEdge: myEdges.r,
            peerEdge: peerEdges.l,
            adjust: { $0.width = $1 - halfW },
            lineOrientation: .vertical,
            linePosition: peerEdges.l,
            start: min(peerEdges.t, myEdges.t),
            end: max(peerEdges.b, myEdges.b)
        )
        trySnap(
            myEdge: myEdges.l,
            peerEdge: peerEdges.r,
            adjust: { $0.width = $1 + halfW },
            lineOrientation: .vertical,
            linePosition: peerEdges.r,
            start: min(peerEdges.t, myEdges.t),
            end: max(peerEdges.b, myEdges.b)
        )
        trySnap(
            myEdge: myEdges.b,
            peerEdge: peerEdges.t,
            adjust: { $0.height = $1 - halfH },
            lineOrientation: .horizontal,
            linePosition: peerEdges.t,
            start: min(peerEdges.l, myEdges.l),
            end: max(peerEdges.r, myEdges.r)
        )
        trySnap(
            myEdge: myEdges.t,
            peerEdge: peerEdges.b,
            adjust: { $0.height = $1 + halfH },
            lineOrientation: .horizontal,
            linePosition: peerEdges.b,
            start: min(peerEdges.l, myEdges.l),
            end: max(peerEdges.r, myEdges.r)
        )
    }

    private func edges(for center: CGSize, halfW: CGFloat, halfH: CGFloat) -> (
        l: CGFloat, r: CGFloat, t: CGFloat, b: CGFloat
    ) {
        (
            center.width - halfW, center.width + halfW, center.height - halfH,
            center.height + halfH
        )
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

    private func handleHaptic(_ guideCount: Int) {
        if guideCount > 0, !hapticEngaged {
            UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
            hapticEngaged = true
        } else if guideCount == 0 {
            hapticEngaged = false
        }
    }

    private func writeToAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(
            image,
            self,
            #selector(saveCompletion(_:didFinishSavingWithError:contextInfo:)),
            nil
        )
    }

    @objc private func saveCompletion(
        _ image: UIImage,
        didFinishSavingWithError error: Error?,
        contextInfo: UnsafeRawPointer
    ) {
        if let error = error {
            showResult(message: error.localizedDescription)
        } else {
            showResult(message: "Image saved successfully!")
        }
    }

    private func showResult(message: String, isError: Bool = false) {
        self.errorMessage = message
        self.showError = true
    }
}
