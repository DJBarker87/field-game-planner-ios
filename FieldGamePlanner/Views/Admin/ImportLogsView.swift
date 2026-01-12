//
//  ImportLogsView.swift
//  FieldGamePlanner
//
//  Created by Claude on 2026-01-11.
//

import SwiftUI

// MARK: - Import Log Model

struct ImportLog: Identifiable, Codable {
    let id: UUID
    let timestamp: Date
    let emailSubject: String
    let matchesImported: Int
    let status: ImportStatus
    let errorMessage: String?

    enum CodingKeys: String, CodingKey {
        case id
        case timestamp = "created_at"
        case emailSubject = "email_subject"
        case matchesImported = "matches_imported"
        case status
        case errorMessage = "error_message"
    }

    enum ImportStatus: String, Codable {
        case success
        case partial
        case failed
    }

    // Preview data
    static var previewList: [ImportLog] {
        [
            ImportLog(
                id: UUID(),
                timestamp: Date().addingTimeInterval(-3600),
                emailSubject: "Field Game Fixtures - Week 1",
                matchesImported: 12,
                status: .success,
                errorMessage: nil
            ),
            ImportLog(
                id: UUID(),
                timestamp: Date().addingTimeInterval(-86400),
                emailSubject: "Field Game Fixtures - Week 2",
                matchesImported: 8,
                status: .partial,
                errorMessage: "4 matches had invalid dates"
            ),
            ImportLog(
                id: UUID(),
                timestamp: Date().addingTimeInterval(-172800),
                emailSubject: "Field Game Fixtures - Week 3",
                matchesImported: 0,
                status: .failed,
                errorMessage: "Email format not recognized"
            ),
        ]
    }
}

// MARK: - Import Logs View

struct ImportLogsView: View {
    @State private var logs: [ImportLog] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    private let supabaseService = SupabaseService.shared

    var body: some View {
        Group {
            if isLoading && logs.isEmpty {
                ProgressView("Loading logs...")
            } else if logs.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                    Text("No Import Logs")
                        .font(.headline)
                    Text("No email imports have been processed yet")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding()
            } else {
                List(logs) { log in
                    ImportLogRow(log: log)
                }
            }
        }
        .navigationTitle("Import Logs")
        .navigationBarTitleDisplayMode(.inline)
        .refreshable {
            await fetchLogs()
        }
        .task {
            await fetchLogs()
        }
    }

    private func fetchLogs() async {
        isLoading = true
        errorMessage = nil

        do {
            // In production, this would fetch from Supabase
            // let response: [ImportLog] = try await supabaseClient
            //     .from("import_log")
            //     .select()
            //     .order("created_at", ascending: false)
            //     .execute()
            //     .value

            // Simulate loading
            try await Task.sleep(nanoseconds: 500_000_000)
            logs = ImportLog.previewList
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}

// MARK: - Import Log Row

struct ImportLogRow: View {
    let log: ImportLog

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Email subject
            Text(log.emailSubject)
                .font(.subheadline)
                .fontWeight(.medium)
                .lineLimit(2)

            // Status and count
            HStack {
                StatusBadge(status: log.status)

                Spacer()

                HStack(spacing: 4) {
                    Image(systemName: "sportscourt")
                        .font(.caption)
                    Text("\(log.matchesImported) matches")
                        .font(.caption)
                }
                .foregroundColor(.secondary)
            }

            // Timestamp
            HStack {
                Image(systemName: "clock")
                    .font(.caption2)
                Text(log.timestamp.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
            }
            .foregroundColor(.secondary)

            // Error message if any
            if let error = log.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.top, 2)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Status Badge

struct StatusBadge: View {
    let status: ImportLog.ImportStatus

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: iconName)
            Text(displayText)
        }
        .font(.caption)
        .fontWeight(.medium)
        .foregroundColor(.white)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(backgroundColor)
        .cornerRadius(4)
    }

    private var iconName: String {
        switch status {
        case .success: return "checkmark.circle"
        case .partial: return "exclamationmark.triangle"
        case .failed: return "xmark.circle"
        }
    }

    private var displayText: String {
        switch status {
        case .success: return "Success"
        case .partial: return "Partial"
        case .failed: return "Failed"
        }
    }

    private var backgroundColor: Color {
        switch status {
        case .success: return .green
        case .partial: return .orange
        case .failed: return .red
        }
    }
}

#Preview {
    NavigationStack {
        ImportLogsView()
    }
}
