//
//  MatchCard.swift
//  FieldGamePlanner
//
//  Created by Claude on 2026-01-11.
//

import SwiftUI

struct MatchCard: View {
    let match: MatchWithHouses
    var showScoreEntry: Bool = false
    var onScoreSubmitted: (() -> Void)?

    private var accessibilityDescription: String {
        var description = "\(match.competitionType): \(match.homeTeamName) versus \(match.awayTeamName ?? "TBD")"
        if match.isCompleted, let homeScore = match.homeScore, let awayScore = match.awayScore {
            description += ". Final score: \(homeScore) to \(awayScore)"
            if let winner = match.winner {
                description += ". \(winner) wins"
            }
        } else {
            description += " on \(match.formattedDate) at \(match.formattedTime)"
        }
        return description
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Competition badge
            Text(match.competitionType)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(match.competitionColor)
                .cornerRadius(4)
                .accessibilityHidden(true)

            // Teams
            HStack {
                TeamView(name: match.homeTeamName, kitColors: match.homeKitColors)
                Spacer()
                if match.isCompleted {
                    ScoreView(homeScore: match.homeScore!, awayScore: match.awayScore!)
                } else {
                    Text("vs")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                TeamView(name: match.awayTeamName ?? "TBD", kitColors: match.awayKitColors)
            }
            .accessibilityHidden(true)

            // Details
            HStack {
                Label(match.formattedDate, systemImage: "calendar")
                Spacer()
                Label(match.formattedTime, systemImage: "clock")
                if let location = match.fullLocationString {
                    Spacer()
                    Label(location, systemImage: "mappin.circle")
                }
            }
            .font(.caption)
            .foregroundColor(.secondary)
            .accessibilityHidden(true)

            // Score entry (only for fixtures, not results)
            if showScoreEntry && !match.isCompleted {
                Divider()
                    .padding(.vertical, 4)

                ScoreEntryView(match: match) {
                    onScoreSubmitted?()
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        .accessibilityElement(children: showScoreEntry && !match.isCompleted ? .contain : .ignore)
        .accessibilityLabel(accessibilityDescription)
        .accessibilityHint(showScoreEntry && !match.isCompleted ? "Tap to enter score" : "Tap to view details")
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
                .lineLimit(1)
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
        .accessibilityHidden(true)
    }
}

struct ScoreView: View {
    let homeScore: Int
    let awayScore: Int

    var body: some View {
        HStack(spacing: 4) {
            Text("\(homeScore)")
                .fontWeight(homeScore > awayScore ? .bold : .regular)
                .foregroundColor(homeScore > awayScore ? .etonPrimary : .primary)
            Text("-")
            Text("\(awayScore)")
                .fontWeight(awayScore > homeScore ? .bold : .regular)
                .foregroundColor(awayScore > homeScore ? .etonPrimary : .primary)
        }
        .font(.title3)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(homeScore) to \(awayScore)")
    }
}

#Preview {
    VStack(spacing: 16) {
        MatchCard(match: .preview)
        MatchCard(match: .preview, showScoreEntry: true)
        MatchCard(match: .completedPreview)
    }
    .padding()
}
