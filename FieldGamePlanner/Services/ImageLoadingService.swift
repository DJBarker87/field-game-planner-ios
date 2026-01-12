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
    let url: URL?
    let size: CGFloat
    let fallbackColors: [Color]

    @State private var image: UIImage?
    @State private var isLoading = false

    init(url: URL?, size: CGFloat = 24, fallbackColors: [Color] = [.gray, .white]) {
        self.url = url
        self.size = size
        self.fallbackColors = fallbackColors
    }

    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: size, height: size)
            } else if isLoading {
                ProgressView()
                    .frame(width: size, height: size)
            } else {
                // Fallback to color stripes
                KitColorIndicator(colors: fallbackColors)
                    .frame(width: size * 0.5, height: size)
            }
        }
        .task {
            await loadImage()
        }
    }

    private func loadImage() async {
        guard let url = url else { return }
        isLoading = true

        do {
            image = try await ImageLoadingService.shared.loadImage(from: url)
        } catch {
            print("Failed to load image from \(url): \(error)")
        }

        isLoading = false
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
