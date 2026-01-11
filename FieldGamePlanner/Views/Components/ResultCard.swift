//
//  ResultCard.swift
//  FieldGamePlanner
//
//  Created by Claude on 2026-01-11.
//

import SwiftUI

struct ResultCard: View {
    let result: MatchResult

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Competition badge
            Text(result.competition)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.competitionColor(for: result.competition))
                .cornerRadius(4)

            // Score
            HStack {
                TeamScoreView(
                    name: result.homeTeam,
                    score: result.homeScore,
                    isWinner: result.homeScore > result.awayScore
                )
                Spacer()
                Text("-")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                TeamScoreView(
                    name: result.awayTeam,
                    score: result.awayScore,
                    isWinner: result.awayScore > result.homeScore
                )
            }

            // Date
            Text(result.formattedDate)
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
    let score: Int
    let isWinner: Bool

    var body: some View {
        VStack(spacing: 4) {
            Text(name)
                .font(.subheadline)
                .fontWeight(isWinner ? .bold : .regular)
                .multilineTextAlignment(.center)
            Text("\(score)")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(isWinner ? .etonGreen : .primary)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    ResultCard(result: MatchResult.preview)
        .padding()
}
