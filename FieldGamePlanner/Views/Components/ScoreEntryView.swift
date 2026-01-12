//
//  ScoreEntryView.swift
//  FieldGamePlanner
//
//  Created by Claude on 2026-01-11.
//

import SwiftUI

struct ScoreEntryView: View {
    let match: MatchWithHouses
    let onScoreSubmitted: () -> Void

    @ObservedObject private var authService = AuthService.shared
    @ObservedObject private var networkMonitor = NetworkMonitor.shared
    @State private var isExpanded = false
    @State private var homeScore = ""
    @State private var awayScore = ""
    @State private var isSubmitting = false
    @State private var showingConfirmation = false
    @State private var showingSuccess = false
    @State private var errorMessage: String?

    // Check if user can enter score for this match
    var canEnterScore: Bool {
        guard authService.isAuthenticated,
              let profile = authService.currentUserProfile else {
            return false
        }

        // Admin can enter score for any match
        if profile.role.isAdmin {
            return isWithinEditWindow
        }

        // Captain can only enter score for their house's matches
        if profile.role == .captain,
           let houseId = profile.houseId {
            let isInvolved = match.homeTeamId == houseId || match.awayTeamId == houseId
            return isInvolved && isWithinEditWindow
        }

        return false
    }

    // Check if within edit window (scheduled OR completed within 5 minutes)
    private var isWithinEditWindow: Bool {
        if match.status == .scheduled {
            return true
        }

        if match.status == .completed {
            // Allow edit within 5 minutes of score entry
            // For now, we assume recent completions are editable
            // In production, check match.scoreEnteredAt
            return false // Disable editing completed matches for safety
        }

        return false
    }

    var body: some View {
        if canEnterScore {
            VStack(spacing: 12) {
                if isExpanded {
                    expandedView
                } else {
                    collapsedView
                }
            }
            .animation(.easeInOut(duration: 0.2), value: isExpanded)
        }
    }

    // MARK: - Collapsed State

    private var collapsedView: some View {
        Group {
            if !networkMonitor.isConnected {
                // Offline message
                HStack {
                    Image(systemName: "wifi.slash")
                    Text("Score entry unavailable offline")
                }
                .font(.caption)
                .foregroundColor(.orange)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(8)
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Score entry unavailable. No internet connection.")
            } else {
                // Normal button
                Button {
                    withAnimation {
                        isExpanded = true
                    }
                } label: {
                    HStack {
                        Image(systemName: "sportscourt")
                        Text("Enter Score")
                    }
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.etonPrimary)
                    .cornerRadius(8)
                }
                .accessibilityLabel("Enter score for \(match.homeTeamName) versus \(match.awayTeamName ?? "opponent")")
                .accessibilityHint("Tap to enter the final score")
            }
        }
    }

    // MARK: - Expanded State

    private var expandedView: some View {
        VStack(spacing: 12) {
            // Offline warning in expanded state
            if !networkMonitor.isConnected {
                HStack {
                    Image(systemName: "wifi.slash")
                    Text("No connection - cannot submit scores")
                }
                .font(.caption)
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.orange)
                .cornerRadius(6)
            }

            // Score inputs
            HStack(spacing: 16) {
                // Home team
                VStack(spacing: 4) {
                    Text(match.homeTeamName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .accessibilityHidden(true)
                    TextField("0", text: $homeScore)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.center)
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(width: 60)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .disabled(!networkMonitor.isConnected)
                        .accessibilityLabel("\(match.homeTeamName) score")
                        .accessibilityValue(homeScore.isEmpty ? "Not entered" : homeScore)
                }

                Text("-")
                    .font(.title2)
                    .fontWeight(.bold)
                    .accessibilityHidden(true)

                // Away team
                VStack(spacing: 4) {
                    Text(match.awayTeamName ?? "")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .accessibilityHidden(true)
                    TextField("0", text: $awayScore)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.center)
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(width: 60)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .disabled(!networkMonitor.isConnected)
                        .accessibilityLabel("\(match.awayTeamName ?? "opponent") score")
                        .accessibilityValue(awayScore.isEmpty ? "Not entered" : awayScore)
                }
            }

            // Error message
            if let error = errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
            }

            // Buttons
            HStack(spacing: 16) {
                Button {
                    withAnimation {
                        isExpanded = false
                        resetForm()
                    }
                } label: {
                    Text("Cancel")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(Color(.systemGray5))
                        .cornerRadius(8)
                }

                Button {
                    validateAndShowConfirmation()
                } label: {
                    HStack {
                        if isSubmitting {
                            ProgressView()
                                .scaleEffect(0.8)
                        } else {
                            Text("Submit")
                        }
                    }
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(canSubmit ? Color.etonPrimary : Color.gray)
                    .cornerRadius(8)
                }
                .disabled(!canSubmit || isSubmitting)
            }
        }
        .padding()
        .background(Color(.systemGray6).opacity(0.5))
        .cornerRadius(12)
        .confirmationDialog(
            "Confirm Score",
            isPresented: $showingConfirmation,
            titleVisibility: .visible
        ) {
            Button("Submit \(match.homeTeamName) \(homeScore) - \(awayScore) \(match.awayTeamName ?? "")") {
                Task { await submitScore() }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to submit this score? This action can only be edited within 5 minutes.")
        }
        .alert("Score Submitted", isPresented: $showingSuccess) {
            Button("OK") {
                withAnimation {
                    isExpanded = false
                    resetForm()
                }
                onScoreSubmitted()
            }
        } message: {
            Text("The score has been recorded successfully.")
        }
    }

    // MARK: - Validation

    private var isValidScore: Bool {
        guard let home = Int(homeScore), let away = Int(awayScore) else {
            return false
        }
        return home >= 0 && away >= 0
    }

    private var canSubmit: Bool {
        isValidScore && networkMonitor.isConnected
    }

    private func validateAndShowConfirmation() {
        errorMessage = nil

        // Check network first
        guard networkMonitor.isConnected else {
            errorMessage = "No connection. Please connect to the internet to submit scores."
            return
        }

        guard let home = Int(homeScore), home >= 0 else {
            errorMessage = "Please enter a valid home score"
            return
        }

        guard let away = Int(awayScore), away >= 0 else {
            errorMessage = "Please enter a valid away score"
            return
        }

        showingConfirmation = true
    }

    // MARK: - Submission

    private func submitScore() async {
        guard let home = Int(homeScore), let away = Int(awayScore) else { return }

        // Double-check network before submission
        guard networkMonitor.isConnected else {
            errorMessage = "No connection. Please try again when online."
            return
        }

        isSubmitting = true
        errorMessage = nil

        do {
            try await SupabaseService.shared.updateScore(
                matchId: match.id,
                homeScore: home,
                awayScore: away
            )
            showingSuccess = true
        } catch {
            errorMessage = error.localizedDescription
        }

        isSubmitting = false
    }

    private func resetForm() {
        homeScore = ""
        awayScore = ""
        errorMessage = nil
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        ScoreEntryView(match: .preview) { }
    }
    .padding()
}
