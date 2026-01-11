//
//  NetworkMonitor.swift
//  FieldGamePlanner
//
//  Created by Claude on 2026-01-11.
//

import Foundation
import Network
import Combine

/// Monitors network connectivity status using NWPathMonitor
@MainActor
class NetworkMonitor: ObservableObject {
    static let shared = NetworkMonitor()

    /// Whether the device has network connectivity
    @Published private(set) var isConnected: Bool = true

    /// The current connection type
    @Published private(set) var connectionType: ConnectionType = .unknown

    /// Whether the connection is expensive (cellular)
    @Published private(set) var isExpensive: Bool = false

    /// Whether the connection is constrained (low data mode)
    @Published private(set) var isConstrained: Bool = false

    private let monitor: NWPathMonitor
    private let queue = DispatchQueue(label: "NetworkMonitor")

    enum ConnectionType {
        case wifi
        case cellular
        case ethernet
        case unknown
    }

    private init() {
        monitor = NWPathMonitor()
        startMonitoring()
    }

    deinit {
        stopMonitoring()
    }

    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor in
                self?.updateConnectionStatus(path)
            }
        }
        monitor.start(queue: queue)
    }

    private func stopMonitoring() {
        monitor.cancel()
    }

    private func updateConnectionStatus(_ path: NWPath) {
        isConnected = path.status == .satisfied
        isExpensive = path.isExpensive
        isConstrained = path.isConstrained

        if path.usesInterfaceType(.wifi) {
            connectionType = .wifi
        } else if path.usesInterfaceType(.cellular) {
            connectionType = .cellular
        } else if path.usesInterfaceType(.wiredEthernet) {
            connectionType = .ethernet
        } else {
            connectionType = .unknown
        }
    }

    /// Check if we have a good connection for data syncing
    var canSync: Bool {
        isConnected && !isConstrained
    }

    /// Human-readable connection status
    var statusDescription: String {
        if !isConnected {
            return "No Connection"
        }

        switch connectionType {
        case .wifi:
            return "Wi-Fi"
        case .cellular:
            return isExpensive ? "Cellular (metered)" : "Cellular"
        case .ethernet:
            return "Ethernet"
        case .unknown:
            return "Connected"
        }
    }
}
