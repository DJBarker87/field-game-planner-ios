//
//  SegmentedControlView.swift
//  FieldGamePlanner
//
//  Created by Claude on 2026-01-12.
//

import SwiftUI

/// A custom segmented control similar to the website's design
struct SegmentedControlView<T: Hashable & Identifiable>: View {
    let options: [T]
    @Binding var selection: T
    let label: (T) -> String

    @Namespace private var animation

    var body: some View {
        HStack(spacing: 4) {
            ForEach(options) { option in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selection = option
                    }
                } label: {
                    Text(label(option))
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                        .background {
                            if selection.id == option.id {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.white)
                                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                                    .matchedGeometryEffect(id: "segment", in: animation)
                            }
                        }
                        .foregroundColor(selection.id == option.id ? .primary : .secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

/// Convenience initializer for TimeFilter
extension SegmentedControlView where T == TimeFilter {
    init(selection: Binding<TimeFilter>) {
        self.options = TimeFilter.allCases
        self._selection = selection
        self.label = { $0.rawValue }
    }
}

/// A simpler version for string-based options
struct SimpleSegmentedControl: View {
    let options: [String]
    @Binding var selection: String

    @Namespace private var animation

    var body: some View {
        HStack(spacing: 4) {
            ForEach(options, id: \.self) { option in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selection = option
                    }
                } label: {
                    Text(option)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                        .background {
                            if selection == option {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.white)
                                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                                    .matchedGeometryEffect(id: "segment", in: animation)
                            }
                        }
                        .foregroundColor(selection == option ? .primary : .secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview("Time Filter") {
    struct PreviewWrapper: View {
        @State private var selected: TimeFilter = .week

        var body: some View {
            VStack(spacing: 20) {
                SegmentedControlView(selection: $selected)

                Text("Selected: \(selected.rawValue)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
        }
    }

    return PreviewWrapper()
}

#Preview("Simple") {
    struct PreviewWrapper: View {
        @State private var selected = "List"

        var body: some View {
            VStack(spacing: 20) {
                SimpleSegmentedControl(
                    options: ["List", "Calendar"],
                    selection: $selected
                )

                Text("Selected: \(selected)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
        }
    }

    return PreviewWrapper()
}
