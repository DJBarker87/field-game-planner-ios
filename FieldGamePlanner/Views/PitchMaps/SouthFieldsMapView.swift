//
//  SouthFieldsMapView.swift
//  FieldGamePlanner
//
//  Created by Claude on 2026-01-11.
//

import SwiftUI

struct SouthFieldsMapView: View {
    var body: some View {
        GeometryReader { geometry in
            Canvas { context, size in
                // Placeholder for South Fields map
                // Will be implemented with actual pitch coordinates
                let rect = CGRect(origin: .zero, size: size)
                context.fill(Path(rect), with: .color(.gray.opacity(0.1)))

                // Draw placeholder text
                let text = Text("South Fields Map")
                    .font(.title2)
                    .foregroundColor(.secondary)
                context.draw(text, at: CGPoint(x: size.width / 2, y: size.height / 2))
            }
        }
        .padding()
    }
}

#Preview {
    SouthFieldsMapView()
}
