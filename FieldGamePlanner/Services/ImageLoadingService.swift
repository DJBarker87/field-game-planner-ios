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
            if let imagePath = imagePath,
               let imageName = extractImageName(from: imagePath),
               let uiImage = UIImage(named: imageName) {
                // Load from app bundle
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: size, height: size)
            } else {
                // Fallback to color stripes
                KitColorIndicator(colors: fallbackColors)
                    .frame(width: size * 0.5, height: size)
            }
        }
    }

    /// Extract image name from path like "/images/houses/angelos.png" -> "angelos"
    private func extractImageName(from path: String) -> String? {
        // Remove leading slash if present
        let cleanPath = path.hasPrefix("/") ? String(path.dropFirst()) : path

        // Extract filename from path
        let components = cleanPath.components(separatedBy: "/")
        guard let filename = components.last else { return nil }

        // Remove file extension
        let nameComponents = filename.components(separatedBy: ".")
        return nameComponents.first
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
