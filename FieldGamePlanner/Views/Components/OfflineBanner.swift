//
//  OfflineBanner.swift
//  FieldGamePlanner
//
//  Created by Claude on 2026-01-11.
//

import SwiftUI

/// Banner displayed when app is using cached data due to offline state
struct OfflineBanner: View {
    let lastUpdated: Date?
    @ObservedObject private var networkMonitor = NetworkMonitor.shared

    private var accessibilityText: String {
        var text = "You're offline. Showing cached data. Some features may be unavailable."
        if let lastUpdated {
            text += " Last updated \(lastUpdated.relativeDescription)."
        }
        return text
    }

    var body: some View {
        if !networkMonitor.isConnected {
            VStack(spacing: 4) {
                HStack(spacing: 8) {
                    Image(systemName: "wifi.slash")
                        .font(.caption)

                    Text("You're offline")
                        .font(.caption)
                        .fontWeight(.medium)

                    Spacer()

                    if let lastUpdated {
                        Text("Updated \(lastUpdated.relativeDescription)")
                            .font(.caption2)
                    }
                }

                Text("Showing cached data. Some features may be unavailable.")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.8))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.orange)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(accessibilityText)
            .accessibilityAddTraits(.isStaticText)
        }
    }
}

/// Compact offline indicator for inline use
struct OfflineIndicator: View {
    @ObservedObject private var networkMonitor = NetworkMonitor.shared

    var body: some View {
        if !networkMonitor.isConnected {
            HStack(spacing: 4) {
                Image(systemName: "wifi.slash")
                Text("Offline")
            }
            .font(.caption)
            .foregroundColor(.orange)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Offline mode")
        }
    }
}

/// View modifier to add offline banner to any view
struct OfflineBannerModifier: ViewModifier {
    let lastUpdated: Date?

    func body(content: Content) -> some View {
        VStack(spacing: 0) {
            OfflineBanner(lastUpdated: lastUpdated)
            content
        }
    }
}

extension View {
    func withOfflineBanner(lastUpdated: Date? = nil) -> some View {
        modifier(OfflineBannerModifier(lastUpdated: lastUpdated))
    }
}

#Preview {
    VStack {
        OfflineBanner(lastUpdated: Date().addingTimeInterval(-300))
        Spacer()
        Text("Content")
        Spacer()
    }
}
