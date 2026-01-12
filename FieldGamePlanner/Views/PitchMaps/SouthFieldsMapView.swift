//
//  SouthFieldsMapView.swift
//  FieldGamePlanner
//
//  Created by Claude on 2026-01-12.
//

import SwiftUI

// MARK: - Pitch Data

private struct PitchData {
    let x: CGFloat
    let y: CGFloat
    let width: CGFloat
    let height: CGFloat
}

private let PITCHES: [String: PitchData] = [
    "Warre's": PitchData(x: 35, y: 105, width: 55, height: 50),
    "Carter's": PitchData(x: 35, y: 165, width: 55, height: 50),
    "Square Close": PitchData(x: 85, y: 330, width: 60, height: 55),

    // South Meadow layout
    "South Meadow 2": PitchData(x: 295, y: 295, width: 55, height: 50),
    "South Meadow 1": PitchData(x: 355, y: 295, width: 55, height: 50),
    "South Meadow 5": PitchData(x: 185, y: 360, width: 45, height: 50),
    "South Meadow 4": PitchData(x: 235, y: 360, width: 45, height: 50),
    "South Meadow 3": PitchData(x: 295, y: 360, width: 55, height: 50),
]

private let MASTERS = PitchData(x: 105, y: 105, width: 70, height: 110)

// MARK: - South Fields Map View

struct SouthFieldsMapView: View {
    let highlightedPitch: String?
    var onPitchTap: ((String) -> Void)?

    init(highlightedPitch: String? = nil, onPitchTap: ((String) -> Void)? = nil) {
        self.highlightedPitch = highlightedPitch
        self.onPitchTap = onPitchTap
    }

    private let viewBox = CGSize(width: 450, height: 470)

    var body: some View {
        GeometryReader { geometry in
            let scale = min(geometry.size.width / viewBox.width, geometry.size.height / viewBox.height)

            Canvas { context, size in
                let transform = CGAffineTransform(scaleX: scale, y: scale)
                    .translatedBy(x: (size.width / scale - viewBox.width) / 2,
                                  y: (size.height / scale - viewBox.height) / 2)

                context.concatenate(transform)

                // Background
                let bgPath = Path(roundedRect: CGRect(x: 0, y: 0, width: 450, height: 470), cornerRadius: 8)
                context.fill(bgPath, with: .color(Color(hex: "#f8faf8")))

                // Title
                context.draw(Text("South Meadow & Surrounds")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(hex: "#374151")),
                    at: CGPoint(x: 225, y: 28))

                // Compass
                drawCompass(context: context, at: CGPoint(x: 415, y: 55))

                // Roads
                drawRoads(context: context)

                // Playground area
                let playgroundPath = Path(roundedRect: CGRect(x: 100, y: 230, width: 60, height: 50), cornerRadius: 3)
                context.fill(playgroundPath, with: .color(Color(hex: "#e8f0e0")))
                context.stroke(playgroundPath, with: .color(Color(hex: "#b8d4a8")), lineWidth: 1)
                context.draw(Text("Playground")
                    .font(.system(size: 8, weight: .medium))
                    .foregroundColor(Color(hex: "#6a8a5a")),
                    at: CGPoint(x: 130, y: 260))

                // Treeline
                drawTreeline(context: context)

                // Path indicator
                context.draw(Text("↓ to Square Close")
                    .font(.system(size: 7).italic())
                    .foregroundColor(Color(hex: "#666666")),
                    at: CGPoint(x: 130, y: 300))

                // Masters' Tennis Courts
                drawMasters(context: context)

                // Pitches
                for (name, data) in PITCHES {
                    drawPitch(context: context, name: name, data: data)
                }
            }
            .gesture(
                SpatialTapGesture()
                    .onEnded { value in
                        handleTap(at: value.location, scale: scale, size: geometry.size)
                    }
            )
        }
        .aspectRatio(viewBox.width / viewBox.height, contentMode: .fit)
    }

    private func drawCompass(context: GraphicsContext, at point: CGPoint) {
        var linePath = Path()
        linePath.move(to: CGPoint(x: point.x, y: point.y + 12))
        linePath.addLine(to: CGPoint(x: point.x, y: point.y - 12))
        context.stroke(linePath, with: .color(Color(hex: "#666666")), lineWidth: 1.5)

        var arrowPath = Path()
        arrowPath.move(to: CGPoint(x: point.x, y: point.y - 12))
        arrowPath.addLine(to: CGPoint(x: point.x - 4, y: point.y - 5))
        arrowPath.addLine(to: CGPoint(x: point.x + 4, y: point.y - 5))
        arrowPath.closeSubpath()
        context.fill(arrowPath, with: .color(Color(hex: "#666666")))

        context.draw(Text("N")
            .font(.system(size: 9))
            .foregroundColor(Color(hex: "#666666")),
            at: CGPoint(x: point.x, y: point.y - 22))
    }

    private func drawRoads(context: GraphicsContext) {
        let roadColor = Color(hex: "#c4c4c4")

        // Eton Wick Road - across the top
        var etonWickPath = Path()
        etonWickPath.move(to: CGPoint(x: 20, y: 90))
        etonWickPath.addLine(to: CGPoint(x: 430, y: 90))
        context.stroke(etonWickPath, with: .color(roadColor), lineWidth: 8)

        context.draw(Text("ETON WICK ROAD")
            .font(.system(size: 9).italic())
            .foregroundColor(Color(hex: "#888888")),
            at: CGPoint(x: 130, y: 77))

        // S Meadow Lane
        var smeadowPath = Path()
        smeadowPath.move(to: CGPoint(x: 420, y: 90))
        smeadowPath.addLine(to: CGPoint(x: 420, y: 250))
        smeadowPath.addLine(to: CGPoint(x: 280, y: 275))
        smeadowPath.addLine(to: CGPoint(x: 165, y: 275))
        smeadowPath.addLine(to: CGPoint(x: 165, y: 430))
        context.stroke(smeadowPath, with: .color(roadColor), style: StrokeStyle(lineWidth: 8, lineCap: .round, lineJoin: .round))

        context.draw(Text("S MEADOW LANE")
            .font(.system(size: 8).italic())
            .foregroundColor(Color(hex: "#888888")),
            at: CGPoint(x: 300, y: 255))

        // Meadow Lane - across the bottom
        var meadowPath = Path()
        meadowPath.move(to: CGPoint(x: 20, y: 430))
        meadowPath.addLine(to: CGPoint(x: 430, y: 430))
        context.stroke(meadowPath, with: .color(roadColor), lineWidth: 8)

        context.draw(Text("MEADOW LANE")
            .font(.system(size: 9).italic())
            .foregroundColor(Color(hex: "#888888")),
            at: CGPoint(x: 320, y: 450))
    }

    private func drawTreeline(context: GraphicsContext) {
        let treeColor = Color(hex: "#4a7a3a")
        let leafColor = Color(hex: "#5a8a4a")

        var treePath = Path()
        treePath.move(to: CGPoint(x: 95, y: 230))
        treePath.addLine(to: CGPoint(x: 95, y: 285))
        treePath.addLine(to: CGPoint(x: 165, y: 285))
        context.stroke(treePath, with: .color(treeColor.opacity(0.7)), style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round))

        // Tree symbols
        let treePositions = [
            CGPoint(x: 95, y: 245),
            CGPoint(x: 95, y: 265),
            CGPoint(x: 115, y: 285),
            CGPoint(x: 140, y: 285)
        ]

        for pos in treePositions {
            let circle = Path(ellipseIn: CGRect(x: pos.x - 4, y: pos.y - 4, width: 8, height: 8))
            context.fill(circle, with: .color(leafColor))
        }
    }

    private func drawMasters(context: GraphicsContext) {
        let rect = CGRect(x: MASTERS.x, y: MASTERS.y, width: MASTERS.width, height: MASTERS.height)
        let mastersPath = Path(roundedRect: rect, cornerRadius: 2)

        context.fill(mastersPath, with: .color(Color(hex: "#f0e6d3")))
        context.stroke(mastersPath, with: .color(Color(hex: "#c9b896")), lineWidth: 1)

        context.draw(Text("Masters'")
            .font(.system(size: 9))
            .foregroundColor(Color(hex: "#8a7a5a")),
            at: CGPoint(x: MASTERS.x + MASTERS.width / 2, y: MASTERS.y + MASTERS.height / 2 - 5))

        context.draw(Text("(tennis)")
            .font(.system(size: 7).italic())
            .foregroundColor(Color(hex: "#a89a7a")),
            at: CGPoint(x: MASTERS.x + MASTERS.width / 2, y: MASTERS.y + MASTERS.height / 2 + 8))
    }

    private func drawPitch(context: GraphicsContext, name: String, data: PitchData) {
        let isHighlighted = isPitchHighlighted(name)

        var baseColor = Color(hex: "#e8f4e8")
        var strokeColor = Color(hex: "#94a894")

        if name.contains("South Meadow") {
            baseColor = Color(hex: "#eef5e8")
            strokeColor = Color(hex: "#a8b898")
        } else if name == "Warre's" || name == "Carter's" {
            baseColor = Color(hex: "#e5efe5")
            strokeColor = Color(hex: "#8db08d")
        } else if name == "Square Close" {
            baseColor = Color(hex: "#e0ede0")
            strokeColor = Color(hex: "#7da67d")
        }

        if isHighlighted {
            baseColor = Color(hex: "#1E4D8C")
            strokeColor = Color(hex: "#15396a")
        }

        let rect = CGRect(x: data.x, y: data.y, width: data.width, height: data.height)
        let pitchPath = Path(roundedRect: rect, cornerRadius: 2)

        context.fill(pitchPath, with: .color(baseColor))
        context.stroke(pitchPath, with: .color(strokeColor), lineWidth: isHighlighted ? 2.5 : 1)

        // Label
        let label = getShortLabel(for: name)
        let fontSize: CGFloat = name == "Square Close" ? 9 : name.contains("South Meadow") ? 10 : 8

        if name == "Square Close" {
            context.draw(Text("SQUARE")
                .font(.system(size: fontSize, weight: isHighlighted ? .semibold : .medium))
                .foregroundColor(isHighlighted ? .white : Color(hex: "#444444")),
                at: CGPoint(x: data.x + data.width / 2, y: data.y + data.height / 2 - 5))
            context.draw(Text("CLOSE")
                .font(.system(size: fontSize, weight: isHighlighted ? .semibold : .medium))
                .foregroundColor(isHighlighted ? .white : Color(hex: "#444444")),
                at: CGPoint(x: data.x + data.width / 2, y: data.y + data.height / 2 + 10))
        } else {
            context.draw(Text(label)
                .font(.system(size: fontSize, weight: isHighlighted ? .semibold : .medium))
                .foregroundColor(isHighlighted ? .white : Color(hex: "#444444")),
                at: CGPoint(x: data.x + data.width / 2, y: data.y + data.height / 2 + 3))
        }
    }

    private func getShortLabel(for name: String) -> String {
        name.replacingOccurrences(of: "South Meadow ", with: "SM")
            .replacingOccurrences(of: "Warre's", with: "WARRE'S")
            .replacingOccurrences(of: "Carter's", with: "CARTER'S")
    }

    private func isPitchHighlighted(_ pitchName: String) -> Bool {
        guard let highlighted = highlightedPitch else { return false }
        let normalizedHighlight = normalizePitchName(highlighted)
        let normalizedPitch = normalizePitchName(pitchName)
        return normalizedHighlight == normalizedPitch ||
               normalizedHighlight.contains(normalizedPitch) ||
               normalizedPitch.contains(normalizedHighlight)
    }

    private func normalizePitchName(_ name: String) -> String {
        name.replacingOccurrences(of: "'", with: "'")
            .replacingOccurrences(of: "`", with: "'")
            .trimmingCharacters(in: .whitespaces)
            .lowercased()
    }

    private func handleTap(at location: CGPoint, scale: CGFloat, size: CGSize) {
        let offsetX = (size.width / scale - viewBox.width) / 2
        let offsetY = (size.height / scale - viewBox.height) / 2
        let x = location.x / scale - offsetX
        let y = location.y / scale - offsetY

        for (name, data) in PITCHES {
            let rect = CGRect(x: data.x, y: data.y, width: data.width, height: data.height)
            if rect.contains(CGPoint(x: x, y: y)) {
                onPitchTap?(name)
                return
            }
        }
    }
}

// MARK: - Preview

#Preview {
    VStack {
        SouthFieldsMapView(highlightedPitch: "South Meadow 3")
            .frame(height: 400)
            .padding()

        SouthFieldsMapView(highlightedPitch: "Warre's")
            .frame(height: 400)
            .padding()
    }
}
