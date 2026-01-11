//
//  MatchCard.swift
//  FieldGamePlanner
//
//  Created by Claude on 2026-01-11.
//

import SwiftUI

struct MatchCard: View {
    let match: Match

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Competition badge
            Text(match.competition)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.competitionColor(for: match.competition))
                .cornerRadius(4)

            // Teams
            HStack {
                TeamView(name: match.homeTeam, kitColors: match.homeKitColors)
                Text("vs")
                    .font(.caption)
                    .foregroundColor(.secondary)
                TeamView(name: match.awayTeam, kitColors: match.awayKitColors)
            }

            // Details
            HStack {
                Label(match.formattedDate, systemImage: "calendar")
                Spacer()
                Label(match.time, systemImage: "clock")
                if let pitch = match.pitch {
                    Spacer()
                    Label(pitch, systemImage: "mappin.circle")
                }
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

struct TeamView: View {
    let name: String
    let kitColors: [Color]

    var body: some View {
        HStack(spacing: 6) {
            KitColorIndicator(colors: kitColors)
            Text(name)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}

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

#Preview {
    MatchCard(match: Match.preview)
        .padding()
}
