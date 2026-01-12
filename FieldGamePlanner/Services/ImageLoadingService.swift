//
//  ImageLoadingService.swift
//  FieldGamePlanner
//
//  Created by Claude on 2026-01-12.
//

import SwiftUI

/// Service for loading and caching house crest images
actor ImageLoadingService {
    static let shared = ImageLoadingService()

    private var cache: [URL: UIImage] = [:]
    private var loadingTasks: [URL: Task<UIImage?, Error>] = [:]

    private init() {}

    /// Load an image from a URL with caching
    /// - Parameter url: The image URL
    /// - Returns: The loaded UIImage or nil if loading fails
    func loadImage(from url: URL) async throws -> UIImage? {
        // Check cache first
        if let cached = cache[url] {
            return cached
        }

        // Check if already loading
        if let existingTask = loadingTasks[url] {
            return try await existingTask.value
        }

        // Create new loading task
        let task = Task<UIImage?, Error> {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let image = UIImage(data: data) else {
                return nil
            }
            return image
        }

        loadingTasks[url] = task

        do {
            let image = try await task.value
            // Cache the image
            if let image = image {
                cache[url] = image
            }
            loadingTasks.removeValue(forKey: url)
            return image
        } catch {
            loadingTasks.removeValue(forKey: url)
            throw error
        }
    }

    /// Clear the image cache
    func clearCache() {
        cache.removeAll()
    }

    /// Remove a specific image from cache
    func removeFromCache(url: URL) {
        cache.removeValue(forKey: url)
    }
}

/// SwiftUI View for loading and displaying house crest images
struct AsyncHouseCrestImage: View {
    let imagePath: String?
    let size: CGFloat
    let fallbackColors: [Color]

    init(imagePath: String?, size: CGFloat = 24, fallbackColors: [Color] = [.gray, .white]) {
        self.imagePath = imagePath
        self.size = size
        self.fallbackColors = fallbackColors
    }

    // Legacy init for URL-based loading (for backward compatibility)
    init(url: URL?, size: CGFloat = 24, fallbackColors: [Color] = [.gray, .white]) {
        self.imagePath = nil
        self.size = size
        self.fallbackColors = fallbackColors
    }

    var body: some View {
        Group {
            if let imagePath = imagePath {
                print("🎨 AsyncHouseCrestImage: imagePath = \(imagePath)")
                if let uiImage = loadImage(from: imagePath) {
                    // Load from app bundle
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: size, height: size)
                } else {
                    // Image load failed, show fallback
                    print("⚠️ Image load failed, showing fallback colors")
                    KitColorIndicator(colors: fallbackColors)
                        .frame(width: size * 0.5, height: size)
                }
            } else {
                // No image path provided
                print("⚠️ AsyncHouseCrestImage: imagePath is NIL, showing fallback colors")
                KitColorIndicator(colors: fallbackColors)
                    .frame(width: size * 0.5, height: size)
            }
        }
    }

    /// Load image from bundle using multiple strategies
    private func loadImage(from path: String) -> UIImage? {
        print("🖼️ Attempting to load image from path: \(path)")

        // Strategy 1: Try Asset Catalog with folder/name format
        if let imageName = extractImageName(from: path),
           let uiImage = UIImage(named: imageName) {
            print("✅ Strategy 1 SUCCESS - Loaded: \(imageName)")
            return uiImage
        }

        // Strategy 2: Try direct filename without folder
        if let filename = path.components(separatedBy: "/").last,
           let name = filename.components(separatedBy: ".").first {
            print("🔍 Strategy 2 - Trying: \(name)")
            if let uiImage = UIImage(named: name) {
                print("✅ Strategy 2 SUCCESS - Loaded: \(name)")
                return uiImage
            }
        }

        // Strategy 3: Try loading from bundle path
        if let bundleImage = loadFromBundle(path: path) {
            print("✅ Strategy 3 SUCCESS")
            return bundleImage
        }

        print("❌ FAILED to load image from: \(path)")
        return nil
    }

    /// Load image from bundle using path
    private func loadFromBundle(path: String) -> UIImage? {
        // Remove leading slash
        let cleanPath = path.hasPrefix("/") ? String(path.dropFirst()) : path

        // Get filename and extension
        let components = cleanPath.components(separatedBy: "/")
        guard let filename = components.last else { return nil }

        let fileComponents = filename.components(separatedBy: ".")
        guard fileComponents.count >= 2 else { return nil }

        let name = fileComponents.dropLast().joined(separator: ".")
        let ext = fileComponents.last!

        // Try to find in bundle
        if let bundlePath = Bundle.main.path(forResource: name, ofType: ext, inDirectory: "houses") {
            return UIImage(contentsOfFile: bundlePath)
        }

        // Try without directory
        if let bundlePath = Bundle.main.path(forResource: name, ofType: ext) {
            return UIImage(contentsOfFile: bundlePath)
        }

        return nil
    }

    /// Extract image name from path like "/images/houses/angelos.png" -> "houses/angelos"
    private func extractImageName(from path: String) -> String? {
        // Remove leading slash if present
        let cleanPath = path.hasPrefix("/") ? String(path.dropFirst()) : path

        // Extract filename and folder from path
        let components = cleanPath.components(separatedBy: "/")

        // Get the last two components (folder and filename)
        // e.g., "images/houses/keate-house.png" -> ["houses", "keate-house.png"]
        guard components.count >= 2 else { return nil }
        let folderName = components[components.count - 2]
        let filename = components[components.count - 1]

        // Remove file extension from filename
        let nameComponents = filename.components(separatedBy: ".")
        guard let name = nameComponents.first else { return nil }

        // Return folder/name format for bundle resources
        return "\(folderName)/\(name)"
    }
}

/// Legacy color indicator view (for backward compatibility)
struct KitColorIndicator: View {
    let colors: [Color]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(colors.indices, id: \.self) { index in
                Rectangle()
                    .fill(colors[index])
                    .frame(width: 8, height: 16)
            }
        }
        .cornerRadius(2)
        .overlay(
            RoundedRectangle(cornerRadius: 2)
                .stroke(Color.gray.opacity(0.3), lineWidth: 0.5)
        )
    }
}
