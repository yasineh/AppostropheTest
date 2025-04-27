//  Created by Yasin Ehsani
//
import SwiftUI

public struct LayoutPicker: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selected: LayoutAspect

    public init(selected: Binding<LayoutAspect>) {
        self._selected = selected
    }

    public var body: some View {
        NavigationView {
            List {
                ForEach(LayoutAspect.allCases) { option in
                    Button {
                        selected = option
                        dismiss()
                    } label: {
                        HStack {
                            Text(option.label)
                            Spacer()
                            Text(option.rawValue).foregroundColor(.secondary)
                            if option == selected {
                                Image(systemName: "checkmark").foregroundColor(
                                    .blue
                                )
                            }
                        }
                    }
                }
            }
            .navigationTitle("Canvas Layouts")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close", action: dismiss.callAsFunction)
                }
            }
        }
    }
}
