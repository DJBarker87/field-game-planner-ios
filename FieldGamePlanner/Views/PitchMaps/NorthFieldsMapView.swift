//
//  NorthFieldsMapView.swift
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
    // Agar's - Left side (vertical orientation)
    "Agar's 5": PitchData(x: 75, y: 90, width: 48, height: 58),
    "Agar's 6": PitchData(x: 128, y: 90, width: 48, height: 58),
    "Agar's 3": PitchData(x: 75, y: 153, width: 48, height: 58),
    "Agar's 4": PitchData(x: 128, y: 153, width: 48, height: 58),
    "Agar's 1": PitchData(x: 75, y: 216, width: 48, height: 58),
    "Agar's 2": PitchData(x: 128, y: 216, width: 48, height: 58),
    "Agar's 7": PitchData(x: 75, y: 289, width: 101, height: 58),

    // Austin's - left of Agar's
    "Austin's": PitchData(x: 38, y: 289, width: 32, height: 58),

    // Dutchman's - Main area
    "O.E. Soccer": PitchData(x: 205, y: 90, width: 101, height: 58),
    "Dutchman's 7": PitchData(x: 311, y: 90, width: 48, height: 58),
    "Dutchman's 5": PitchData(x: 205, y: 153, width: 48, height: 58),
    "Dutchman's 6": PitchData(x: 258, y: 153, width: 48, height: 58),
    "Dutchman's 8": PitchData(x: 311, y: 153, width: 48, height: 58),
    "Dutchman's 3": PitchData(x: 205, y: 216, width: 48, height: 58),
    "Dutchman's 4": PitchData(x: 258, y: 216, width: 48, height: 58),
    "Dutchman's 1": PitchData(x: 205, y: 289, width: 48, height: 58),
    "Dutchman's 2": PitchData(x: 258, y: 289, width: 48, height: 58),
    "Dutchman's 15": PitchData(x: 311, y: 289, width: 48, height: 58),

    // D9-D12 column
    "Dutchman's 12": PitchData(x: 385, y: 100, width: 52, height: 38),
    "Dutchman's 11": PitchData(x: 385, y: 143, width: 52, height: 38),
    "Dutchman's 10": PitchData(x: 385, y: 186, width: 52, height: 38),
    "Dutchman's 9": PitchData(x: 385, y: 229, width: 52, height: 38),

    // D13, D14 (right of footpath)
    "Dutchman's 13": PitchData(x: 462, y: 125, width: 52, height: 38),
    "Dutchman's 14": PitchData(x: 462, y: 168, width: 52, height: 38),

    // College Field
    "College Field": PitchData(x: 75, y: 410, width: 90, height: 45),
]

// MARK: - North Fields Map View

struct NorthFieldsMapView: View {
    let highlightedPitch: String?
    var onPitchTap: ((String) -> Void)?

    init(highlightedPitch: String? = nil, onPitchTap: ((String) -> Void)? = nil) {
        self.highlightedPitch = highlightedPitch
        self.onPitchTap = onPitchTap
    }

    private let viewBox = CGSize(width: 540, height: 480)

    var body: some View {
        GeometryReader { geometry in
            let scale = min(geometry.size.width / viewBox.width, geometry.size.height / viewBox.height)

            Canvas { context, size in
                let transform = CGAffineTransform(scaleX: scale, y: scale)
                    .translatedBy(x: (size.width / scale - viewBox.width) / 2,
                                  y: (size.height / scale - viewBox.height) / 2)

                context.concatenate(transform)

                // Background
                let bgPath = Path(roundedRect: CGRect(x: 0, y: 0, width: 540, height: 480), cornerRadius: 8)
                context.fill(bgPath, with: .color(Color(hex: "#f8faf8")))

                // Title
                context.draw(Text("Agar's & Dutchman's")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(hex: "#374151")),
                    at: CGPoint(x: 270, y: 28))

                // Compass
                drawCompass(context: context, at: CGPoint(x: 505, y: 55))

                // Roads
                drawRoads(context: context)

                // Area Labels
                context.draw(Text("AGAR'S")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(Color(hex: "#555555")),
                    at: CGPoint(x: 113, y: 78))

                context.draw(Text("DUTCHMAN'S")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(Color(hex: "#555555")),
                    at: CGPoint(x: 285, y: 78))

                // Pavilion
                let pavPath = Path(roundedRect: CGRect(x: 100, y: 355, width: 50, height: 22), cornerRadius: 2)
                context.fill(pavPath, with: .color(Color(hex: "#d4c4a8")))
                context.stroke(pavPath, with: .color(Color(hex: "#a89878")), lineWidth: 1)
                context.draw(Text("PAV")
                    .font(.system(size: 8, weight: .medium))
                    .foregroundColor(Color(hex: "#665544")),
                    at: CGPoint(x: 125, y: 370))

                // Athletics area
                let athPath = Path(roundedRect: CGRect(x: 385, y: 280, width: 55, height: 40), cornerRadius: 3)
                context.stroke(athPath, with: .color(Color(hex: "#d1d5db")), style: StrokeStyle(lineWidth: 1, dash: [3, 2]))
                context.draw(Text("Athletics")
                    .font(.system(size: 7).italic())
                    .foregroundColor(Color(hex: "#aaaaaa")),
                    at: CGPoint(x: 412, y: 305))

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
        let roadColor = Color(hex: "#d1d5db")

        // Slough Road - left edge
        var sloughPath = Path()
        sloughPath.move(to: CGPoint(x: 30, y: 70))
        sloughPath.addLine(to: CGPoint(x: 30, y: 360))
        context.stroke(sloughPath, with: .color(roadColor), lineWidth: 8)

        // Avenue - between Agar's and Dutchman's
        var avenuePath = Path()
        avenuePath.move(to: CGPoint(x: 186, y: 70))
        avenuePath.addLine(to: CGPoint(x: 186, y: 360))
        context.stroke(avenuePath, with: .color(roadColor), lineWidth: 6)

        // Footpath
        var footpathPath = Path()
        footpathPath.move(to: CGPoint(x: 447, y: 85))
        footpathPath.addLine(to: CGPoint(x: 447, y: 290))
        context.stroke(footpathPath, with: .color(roadColor), style: StrokeStyle(lineWidth: 4, dash: [4, 3]))

        // Pocock's Lane - horizontal
        var pocockPath = Path()
        pocockPath.move(to: CGPoint(x: 25, y: 380))
        pocockPath.addLine(to: CGPoint(x: 530, y: 380))
        context.stroke(pocockPath, with: .color(roadColor), lineWidth: 6)

        // Road labels
        context.draw(Text("POCOCK'S LANE")
            .font(.system(size: 8).italic())
            .foregroundColor(Color(hex: "#9ca3af")),
            at: CGPoint(x: 420, y: 390))
    }

    private func drawPitch(context: GraphicsContext, name: String, data: PitchData) {
        let isHighlighted = isPitchHighlighted(name)

        var baseColor = Color(hex: "#e8f4e8")
        var strokeColor = Color(hex: "#94a894")

        if name.contains("Agar") {
            baseColor = Color(hex: "#e0ede0")
            strokeColor = Color(hex: "#7da67d")
        } else if name.contains("Dutchman") || name == "O.E. Soccer" {
            baseColor = Color(hex: "#e5f0e5")
            strokeColor = Color(hex: "#8db08d")
        } else if name == "College Field" {
            baseColor = Color(hex: "#d8e8d8")
            strokeColor = Color(hex: "#6a9a6a")
        } else if name == "Austin's" {
            baseColor = Color(hex: "#e8ece8")
            strokeColor = Color(hex: "#8a9a8a")
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
        let fontSize: CGFloat = data.width < 45 ? 7 : data.width < 55 ? 8 : 9

        context.draw(Text(label)
            .font(.system(size: fontSize, weight: isHighlighted ? .semibold : .medium))
            .foregroundColor(isHighlighted ? .white : Color(hex: "#444444")),
            at: CGPoint(x: data.x + data.width / 2, y: data.y + data.height / 2 + 3))
    }

    private func getShortLabel(for name: String) -> String {
        name.replacingOccurrences(of: "Dutchman's ", with: "D")
            .replacingOccurrences(of: "Agar's ", with: "A")
            .replacingOccurrences(of: "O.E. Soccer", with: "O.E.")
            .replacingOccurrences(of: "Austin's", with: "AUS")
            .replacingOccurrences(of: "College Field", with: "COLLEGE")
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
            .replacingOccurrences(of: "Dutchmna's", with: "Dutchman's")
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
        NorthFieldsMapView(highlightedPitch: "Dutchman's 5")
            .frame(height: 400)
            .padding()

        NorthFieldsMapView(highlightedPitch: "Agar's 3")
            .frame(height: 400)
            .padding()
    }
}
