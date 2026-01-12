//
//  StandingRow.swift
//  FieldGamePlanner
//
//  Created by Claude on 2026-01-11.
//

import SwiftUI

struct StandingRow: View {
    let standing: LeagueStanding
    let position: Int

    var body: some View {
        HStack {
            // Position
            Text("\(position)")
                .font(.headline)
                .fontWeight(.bold)
                .frame(width: 30)
                .foregroundColor(positionColor)

            // Kit colors
            KitColorIndicator(colors: standing.parsedColours)

            // Team name
            Text(standing.teamName)
                .font(.subheadline)
                .fontWeight(.medium)

            Spacer()

            // Stats
            HStack(spacing: 12) {
                StatColumn(label: "P", value: standing.played)
                StatColumn(label: "W", value: standing.wins)
                StatColumn(label: "D", value: standing.draws)
                StatColumn(label: "L", value: standing.losses)
                StatColumn(label: "GD", value: standing.goalDifference, showSign: true)
                StatColumn(label: "Pts", value: standing.points, highlighted: true)
            }
        }
        .padding(.vertical, 4)
    }

    private var positionColor: Color {
        switch position {
        case 1: return .etonPrimary
        case 2, 3: return .eton600
        default: return .primary
        }
    }
}

struct StatColumn: View {
    let label: String
    let value: Int
    var showSign: Bool = false
    var highlighted: Bool = false

    var body: some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
            Text(displayValue)
                .font(.caption)
                .fontWeight(highlighted ? .bold : .regular)
                .foregroundColor(highlighted ? .etonPrimary : textColor)
        }
        .frame(width: 28)
    }

    private var displayValue: String {
        if showSign && value > 0 {
            return "+\(value)"
        }
        return "\(value)"
    }

    private var textColor: Color {
        if showSign {
            if value > 0 { return .green }
            if value < 0 { return .red }
        }
        return .primary
    }
}

#Preview {
    List {
        ForEach(Array(LeagueStanding.previewList.enumerated()), id: \.element.id) { index, standing in
            StandingRow(standing: standing, position: index + 1)
        }
    }
}
