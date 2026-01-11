//
//  StandingRow.swift
//  FieldGamePlanner
//
//  Created by Claude on 2026-01-11.
//

import SwiftUI

struct StandingRow: View {
    let standing: Standing

    var body: some View {
        HStack {
            // Position
            Text("\(standing.position)")
                .font(.headline)
                .fontWeight(.bold)
                .frame(width: 30)

            // Team name
            Text(standing.teamName)
                .font(.subheadline)

            Spacer()

            // Stats
            HStack(spacing: 16) {
                StatView(label: "P", value: standing.played)
                StatView(label: "W", value: standing.wins)
                StatView(label: "D", value: standing.draws)
                StatView(label: "L", value: standing.losses)
                StatView(label: "Pts", value: standing.points, highlighted: true)
            }
        }
        .padding(.vertical, 4)
    }
}

struct StatView: View {
    let label: String
    let value: Int
    var highlighted: Bool = false

    var body: some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
            Text("\(value)")
                .font(.caption)
                .fontWeight(highlighted ? .bold : .regular)
                .foregroundColor(highlighted ? .etonGreen : .primary)
        }
        .frame(width: 24)
    }
}

#Preview {
    List {
        StandingRow(standing: Standing.preview)
    }
}
