//
//  CacheService.swift
//  FieldGamePlanner
//
//  Created by Claude on 2026-01-11.
//

import Foundation

actor CacheService {
    static let shared = CacheService()

    private let cache = NSCache<NSString, CacheEntry>()
    private var expirations: [String: Date] = [:]

    private let defaultExpiration: TimeInterval = 5 * 60 // 5 minutes

    private init() {
        cache.countLimit = 100
    }

    func set<T: Codable>(_ value: T, forKey key: String, expiration: TimeInterval? = nil) {
        let entry = CacheEntry(value: value)
        cache.setObject(entry, forKey: key as NSString)
        expirations[key] = Date().addingTimeInterval(expiration ?? defaultExpiration)
    }

    func get<T: Codable>(forKey key: String) -> T? {
        guard let expiration = expirations[key], Date() < expiration else {
            remove(forKey: key)
            return nil
        }

        guard let entry = cache.object(forKey: key as NSString) else {
            return nil
        }

        return entry.value as? T
    }

    func remove(forKey key: String) {
        cache.removeObject(forKey: key as NSString)
        expirations.removeValue(forKey: key)
    }

    func clearAll() {
        cache.removeAllObjects()
        expirations.removeAll()
    }
}

private class CacheEntry: NSObject {
    let value: Any

    init(value: Any) {
        self.value = value
    }
}
