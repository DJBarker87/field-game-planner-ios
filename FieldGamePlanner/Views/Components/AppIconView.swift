import SwiftUI

/// App Icon design - Field game goalpost silhouette in Eton green on white
/// This view can be rendered at 1024x1024 and exported as PNG for App Store
struct AppIconView: View {
    let size: CGFloat

    // Eton Green colors
    private let etonGreen = Color(red: 0.588, green: 0.784, blue: 0.635) // #96c8a2
    private let etonGreenDark = Color(red: 0.322, green: 0.549, blue: 0.380) // #528c61

    var body: some View {
        ZStack {
            // White background with subtle gradient
            LinearGradient(
                colors: [.white, Color(white: 0.97)],
                startPoint: .top,
                endPoint: .bottom
            )

            // Goalpost silhouette
            GoalpostShape()
                .fill(etonGreen)
                .frame(width: size * 0.7, height: size * 0.5)
                .offset(y: size * 0.05)

            // Subtle shadow for depth
            GoalpostShape()
                .fill(etonGreenDark.opacity(0.3))
                .frame(width: size * 0.7, height: size * 0.5)
                .offset(x: size * 0.01, y: size * 0.06)
                .blur(radius: size * 0.02)
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: size * 0.2237)) // iOS icon corner radius ratio
    }
}

/// Field game goalpost shape - two vertical posts with horizontal crossbar and net suggestion
struct GoalpostShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        let postWidth = rect.width * 0.08
        let crossbarHeight = rect.height * 0.08
        let groundLevel = rect.height * 0.85
        let postTop = rect.height * 0.15
        let netInset = rect.width * 0.15

        // Left post
        path.addRect(CGRect(
            x: netInset - postWidth / 2,
            y: postTop,
            width: postWidth,
            height: groundLevel - postTop
        ))

        // Right post
        path.addRect(CGRect(
            x: rect.width - netInset - postWidth / 2,
            y: postTop,
            width: postWidth,
            height: groundLevel - postTop
        ))

        // Crossbar
        path.addRect(CGRect(
            x: netInset - postWidth / 2,
            y: postTop,
            width: rect.width - 2 * netInset + postWidth,
            height: crossbarHeight
        ))

        // Net suggestion (simplified triangular back)
        let netTop = postTop + crossbarHeight
        let netDepth = rect.height * 0.15

        // Left net side
        path.move(to: CGPoint(x: netInset - postWidth / 2, y: netTop))
        path.addLine(to: CGPoint(x: netInset * 0.5, y: netTop + netDepth))
        path.addLine(to: CGPoint(x: netInset * 0.5, y: groundLevel))
        path.addLine(to: CGPoint(x: netInset - postWidth / 2, y: groundLevel))
        path.closeSubpath()

        // Right net side
        path.move(to: CGPoint(x: rect.width - netInset + postWidth / 2, y: netTop))
        path.addLine(to: CGPoint(x: rect.width - netInset * 0.5, y: netTop + netDepth))
        path.addLine(to: CGPoint(x: rect.width - netInset * 0.5, y: groundLevel))
        path.addLine(to: CGPoint(x: rect.width - netInset + postWidth / 2, y: groundLevel))
        path.closeSubpath()

        // Back net top
        path.move(to: CGPoint(x: netInset * 0.5, y: netTop + netDepth))
        path.addLine(to: CGPoint(x: rect.width - netInset * 0.5, y: netTop + netDepth))
        path.addLine(to: CGPoint(x: rect.width - netInset + postWidth / 2, y: netTop))
        path.addLine(to: CGPoint(x: netInset - postWidth / 2, y: netTop))
        path.closeSubpath()

        return path
    }
}

/// Preview for design iteration
#Preview("App Icon 1024") {
    AppIconView(size: 1024)
        .frame(width: 300, height: 300)
}

#Preview("App Icon Small") {
    AppIconView(size: 60)
}

// MARK: - Icon Export Helper

#if DEBUG
import Foundation

extension View {
    /// Render this view to a PNG image at the specified size
    /// Usage in Xcode Previews or a simple app to export the icon
    @MainActor
    func renderToImage(size: CGSize) -> UIImage? {
        let renderer = ImageRenderer(content: self.frame(width: size.width, height: size.height))
        renderer.scale = 1.0
        return renderer.uiImage
    }
}

/// Helper view to export the app icon - run this in a preview or test
struct AppIconExporter: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("App Icon Preview")
                .font(.headline)

            AppIconView(size: 1024)
                .frame(width: 256, height: 256)
                .shadow(radius: 10)

            Text("To export: Use Xcode's 'Export as Image' in Preview")
                .font(.caption)
                .foregroundStyle(.secondary)

            Text("Or run the exportAppIcon() function")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
    }

    /// Export the app icon to the Documents directory
    @MainActor
    func exportAppIcon() {
        let iconView = AppIconView(size: 1024)
        let renderer = ImageRenderer(content: iconView)
        renderer.scale = 1.0

        if let image = renderer.uiImage,
           let data = image.pngData() {
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let iconPath = documentsPath.appendingPathComponent("AppIcon-1024.png")

            do {
                try data.write(to: iconPath)
                print("App icon exported to: \(iconPath.path)")
            } catch {
                print("Failed to export icon: \(error)")
            }
        }
    }
}

#Preview("Icon Exporter") {
    AppIconExporter()
}
#endif
