//
//  ResultCard.swift
//  FieldGamePlanner
//
//  Created by Claude on 2026-01-11.
//

import SwiftUI

struct ResultCard: View {
    let result: MatchWithHouses

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Competition badge
            Text(result.competitionType)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(result.competitionColor)
                .cornerRadius(4)

            // Score
            HStack {
                TeamScoreView(
                    name: result.homeTeamName,
                    colors: result.homeKitColors,
                    score: result.homeScore ?? 0,
                    isWinner: (result.homeScore ?? 0) > (result.awayScore ?? 0)
                )
                Spacer()
                Text("-")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                TeamScoreView(
                    name: result.awayTeamName ?? "TBD",
                    colors: result.awayKitColors,
                    score: result.awayScore ?? 0,
                    isWinner: (result.awayScore ?? 0) > (result.homeScore ?? 0)
                )
            }

            // Date and location
            HStack {
                Text(result.formattedDate)
                if let location = result.fullLocationString {
                    Spacer()
                    Text(location)
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

struct TeamScoreView: View {
    let name: String
    let colors: [Color]
    let score: Int
    let isWinner: Bool

    var body: some View {
        VStack(spacing: 4) {
            KitColorIndicator(colors: colors)
            Text(name)
                .font(.subheadline)
                .fontWeight(isWinner ? .bold : .regular)
                .multilineTextAlignment(.center)
                .lineLimit(2)
            Text("\(score)")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(isWinner ? .etonPrimary : .primary)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    ResultCard(result: .completedPreview)
        .padding()
}
