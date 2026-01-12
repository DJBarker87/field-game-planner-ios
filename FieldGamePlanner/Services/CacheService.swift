//
//  CacheService.swift
//  FieldGamePlanner
//
//  Created by Claude on 2026-01-11.
//

import Foundation

/// Thread-safe caching service with memory and disk storage
actor CacheService {
    static let shared = CacheService()

    // MARK: - Memory Cache

    private let memoryCache = NSCache<NSString, CacheEntry>()
    private var expirations: [String: Date] = [:]

    /// Default time-to-live for cached items (5 minutes)
    private let defaultTTL: TimeInterval = 300

    // MARK: - Disk Cache

    private let fileManager = FileManager.default
    private let diskCacheDirectory: URL

    // MARK: - Initialization

    private init() {
        // Set up memory cache limits
        memoryCache.countLimit = 100
        memoryCache.totalCostLimit = 50 * 1024 * 1024 // 50 MB

        // Set up disk cache directory
        let cacheDir = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        diskCacheDirectory = cacheDir.appendingPathComponent("FieldGamePlannerCache", isDirectory: true)

        // Create directory if needed
        try? fileManager.createDirectory(at: diskCacheDirectory, withIntermediateDirectories: true)
    }

    // MARK: - Memory Cache Operations

    /// Get a value from memory cache
    /// - Parameters:
    ///   - key: The cache key
    ///   - type: The expected type of the cached value
    /// - Returns: The cached value or nil if not found/expired
    func get<T: Codable>(_ key: String, type: T.Type) -> T? {
        // Check expiration
        if let expiration = expirations[key], Date() >= expiration {
            remove(key)
            return nil
        }

        // Get from cache
        guard let entry = memoryCache.object(forKey: key as NSString) else {
            return nil
        }

        return entry.value as? T
    }

    /// Set a value in memory cache
    /// - Parameters:
    ///   - key: The cache key
    ///   - value: The value to cache
    ///   - ttl: Time-to-live in seconds (defaults to 300)
    func set<T: Codable>(_ key: String, value: T, ttl: TimeInterval? = nil) {
        let entry = CacheEntry(value: value)
        let cost = MemoryLayout.size(ofValue: value)
        memoryCache.setObject(entry, forKey: key as NSString, cost: cost)
        expirations[key] = Date().addingTimeInterval(ttl ?? defaultTTL)
    }

    /// Remove a value from memory cache
    /// - Parameter key: The cache key to remove
    func remove(_ key: String) {
        memoryCache.removeObject(forKey: key as NSString)
        expirations.removeValue(forKey: key)
    }

    /// Clear all items from memory cache
    func clearMemory() {
        memoryCache.removeAllObjects()
        expirations.removeAll()
    }

    // MARK: - Disk Cache Operations

    /// Persist a value to disk cache
    /// - Parameters:
    ///   - key: The cache key
    ///   - value: The value to persist
    func persistToDisk<T: Codable>(_ key: String, value: T) async throws {
        let fileURL = diskFileURL(for: key)

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        let wrapper = DiskCacheWrapper(value: value, timestamp: Date())
        let data = try encoder.encode(wrapper)

        try data.write(to: fileURL, options: .atomic)
    }

    /// Load a value from disk cache
    /// - Parameters:
    ///   - key: The cache key
    ///   - type: The expected type
    ///   - maxAge: Maximum age in seconds (nil = no expiration)
    /// - Returns: The cached value or nil if not found/expired
    func loadFromDisk<T: Codable>(_ key: String, type: T.Type, maxAge: TimeInterval? = nil) async throws -> T? {
        let fileURL = diskFileURL(for: key)

        guard fileManager.fileExists(atPath: fileURL.path) else {
            return nil
        }

        let data = try Data(contentsOf: fileURL)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let wrapper = try decoder.decode(DiskCacheWrapper<T>.self, from: data)

        // Check expiration if maxAge specified
        if let maxAge = maxAge {
            let age = Date().timeIntervalSince(wrapper.timestamp)
            if age > maxAge {
                try? fileManager.removeItem(at: fileURL)
                return nil
            }
        }

        return wrapper.value
    }

    /// Remove a value from disk cache
    /// - Parameter key: The cache key to remove
    func removeFromDisk(_ key: String) async {
        let fileURL = diskFileURL(for: key)
        try? fileManager.removeItem(at: fileURL)
    }

    /// Clear all items from disk cache
    func clearDisk() async {
        try? fileManager.removeItem(at: diskCacheDirectory)
        try? fileManager.createDirectory(at: diskCacheDirectory, withIntermediateDirectories: true)
    }

    /// Clear both memory and disk caches
    func clearAll() async {
        clearMemory()
        await clearDisk()
    }

    // MARK: - Convenience Methods

    /// Get from memory cache, falling back to disk if not in memory
    /// - Parameters:
    ///   - key: The cache key
    ///   - type: The expected type
    ///   - diskMaxAge: Maximum age for disk cache entries
    /// - Returns: The cached value or nil
    func getWithDiskFallback<T: Codable>(
        _ key: String,
        type: T.Type,
        diskMaxAge: TimeInterval? = 3600
    ) async -> T? {
        // Try memory first
        if let value: T = get(key, type: type) {
            return value
        }

        // Fall back to disk
        if let value = try? await loadFromDisk(key, type: type, maxAge: diskMaxAge) {
            // Restore to memory cache
            set(key, value: value)
            return value
        }

        return nil
    }

    /// Set in both memory and disk cache
    /// - Parameters:
    ///   - key: The cache key
    ///   - value: The value to cache
    ///   - ttl: Memory cache TTL
    func setWithDiskPersistence<T: Codable>(_ key: String, value: T, ttl: TimeInterval? = nil) async {
        set(key, value: value, ttl: ttl)
        try? await persistToDisk(key, value: value)
    }

    // MARK: - Cache Statistics

    /// Get disk cache size in bytes
    var diskCacheSize: Int64 {
        get async {
            guard let enumerator = fileManager.enumerator(
                at: diskCacheDirectory,
                includingPropertiesForKeys: [.fileSizeKey],
                options: [.skipsHiddenFiles]
            ) else {
                return 0
            }

            var totalSize: Int64 = 0
            while let fileURL = enumerator.nextObject() as? URL {
                if let size = try? fileURL.resourceValues(forKeys: [.fileSizeKey]).fileSize {
                    totalSize += Int64(size)
                }
            }
            return totalSize
        }
    }

    /// Get number of items in memory cache
    var memoryCacheCount: Int {
        expirations.count
    }

    // MARK: - Private Helpers

    private func diskFileURL(for key: String) -> URL {
        let safeKey = key.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? key
        return diskCacheDirectory.appendingPathComponent("\(safeKey).json")
    }
}

// MARK: - Supporting Types

/// Wrapper for memory cache entries
private class CacheEntry: NSObject {
    let value: Any

    init(value: Any) {
        self.value = value
    }
}

/// Wrapper for disk cache entries with timestamp
private struct DiskCacheWrapper<T: Codable>: Codable {
    let value: T
    let timestamp: Date
}

// MARK: - Cache Keys

/// Predefined cache keys for the app
enum CacheKey {
    static let houses = "houses"
    static let upcomingMatches = "upcoming_matches"
    static let recentResults = "recent_results"
    static let standings = "standings"
    static let userProfile = "user_profile"

    static func matches(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return "matches_\(formatter.string(from: date))"
    }

    static func standings(for competition: String) -> String {
        "standings_\(competition.lowercased().replacingOccurrences(of: " ", with: "_"))"
    }

    static func team(_ teamId: String) -> String {
        "team_\(teamId)"
    }
}
