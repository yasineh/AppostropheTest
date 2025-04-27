//  Created by Yasin Ehsani
//

import SwiftUI

public struct OverlayPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm = OverlayPickerViewModel()

    let onSelect: (Overlay) -> Void
    private let columns = Array(
        repeating: GridItem(.flexible(minimum: 80), spacing: 12),
        count: 2
    )

    public init(onSelect: @escaping (Overlay) -> Void) {
        self.onSelect = onSelect
    }

    public var body: some View {
        NavigationView {
            content
                .navigationTitle("Overlays")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Close", action: dismiss.callAsFunction)
                    }
                }
                .task { await vm.load() }
        }
    }

    @ViewBuilder
    private var content: some View {
        if vm.isLoading {
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let error = vm.error {
            VStack(spacing: 12) {
                Text("Error: \(error)")
                Button {
                    vm.error = nil
                    vm.isLoading = true
                    Task { await vm.load() }
                } label: {
                    Label("Retry", systemImage: "arrow.clockwise")
                        .font(.headline)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(vm.overlays) { overlay in
                        OverlayThumbnail(url: overlay.url)
                            .frame(height: 100)
                            .clipped()
                            .cornerRadius(8)
                            .onTapGesture {
                                onSelect(overlay)
                                dismiss()
                            }
                    }
                }
                .padding()
            }
        }
    }
}
