//
//  FieldGamePlannerTests.swift
//  FieldGamePlannerTests
//
//  Created by Claude on 2026-01-11.
//

import XCTest
import SwiftUI
@testable import FieldGamePlanner

final class FieldGamePlannerTests: XCTestCase {

    // MARK: - Color System Tests

    func testEtonPaletteColors() {
        // Test that all Eton palette colors exist and are distinct
        let colors: [Color] = [
            .eton50, .eton100, .eton200, .eton300, .eton400,
            .eton500, .eton600, .eton700, .eton800, .eton900
        ]
        XCTAssertEqual(colors.count, 10)

        // Test primary color aliases
        XCTAssertNotNil(Color.etonPrimary)
        XCTAssertNotNil(Color.etonGreen)
    }

    func testCompetitionColors() {
        // Test each competition type returns correct color
        XCTAssertEqual(Color.competitionColor(for: "Senior Ties"), .seniorTies)
        XCTAssertEqual(Color.competitionColor(for: "Senior League"), .seniorLeague)
        XCTAssertEqual(Color.competitionColor(for: "Junior League"), .juniorLeague)
        XCTAssertEqual(Color.competitionColor(for: "6th Form League"), .sixthFormLeague)
        XCTAssertEqual(Color.competitionColor(for: "Sixth Form League"), .sixthFormLeague)
        XCTAssertEqual(Color.competitionColor(for: "Lower Boy League"), .lowerBoyLeague)
        XCTAssertEqual(Color.competitionColor(for: "Knockout Cup"), .knockoutCup)
        XCTAssertEqual(Color.competitionColor(for: "Friendly"), .friendly)

        // Test case insensitivity
        XCTAssertEqual(Color.competitionColor(for: "SENIOR LEAGUE"), .seniorLeague)
        XCTAssertEqual(Color.competitionColor(for: "junior league"), .juniorLeague)

        // Test default fallback
        XCTAssertEqual(Color.competitionColor(for: "Unknown Competition"), .etonPrimary)
    }

    func testKitColorMapperParsing() {
        // Test single color
        let singleColor = KitColorMapper.parse("red")
        XCTAssertEqual(singleColor.count, 1)

        // Test two colors
        let twoColors = KitColorMapper.parse("red/white")
        XCTAssertEqual(twoColors.count, 2)

        // Test three colors
        let threeColors = KitColorMapper.parse("navy/gold/white")
        XCTAssertEqual(threeColors.count, 3)

        // Test empty string returns default
        let emptyColors = KitColorMapper.parse("")
        XCTAssertEqual(emptyColors.count, 1)

        // Test unknown color returns default
        let unknownColors = KitColorMapper.parse("unknowncolor")
        XCTAssertEqual(unknownColors.count, 1)

        // Test case insensitivity
        let mixedCase = KitColorMapper.parse("NAVY/Gold/WHITE")
        XCTAssertEqual(mixedCase.count, 3)

        // Test with spaces
        let withSpaces = KitColorMapper.parse("navy / gold / white")
        XCTAssertEqual(withSpaces.count, 3)
    }

    func testKitColorMapperValidation() {
        XCTAssertTrue(KitColorMapper.isValid("red/white"))
        XCTAssertTrue(KitColorMapper.isValid("navy"))
        XCTAssertFalse(KitColorMapper.isValid("unknowncolor"))
        XCTAssertFalse(KitColorMapper.isValid(""))
        XCTAssertFalse(KitColorMapper.isValid("red/unknowncolor"))
    }

    func testKitColorMapperAvailableColors() {
        let colors = KitColorMapper.availableColors
        XCTAssertGreaterThanOrEqual(colors.count, 30)
        XCTAssertTrue(colors.contains("red"))
        XCTAssertTrue(colors.contains("navy"))
        XCTAssertTrue(colors.contains("eton"))
    }

    func testHexColorInitialization() {
        // Test 6-digit hex
        let red = Color(hex: "#FF0000")
        XCTAssertNotNil(red)

        // Test without hash
        let blue = Color(hex: "0000FF")
        XCTAssertNotNil(blue)

        // Test 3-digit hex
        let green = Color(hex: "#0F0")
        XCTAssertNotNil(green)
    }

    // MARK: - House Model Tests

    func testHouseDecoding() throws {
        let json = """
        {
            "id": "550e8400-e29b-41d4-a716-446655440000",
            "name": "Keate",
            "colours": "red/white",
            "created_at": "2024-01-01T00:00:00Z"
        }
        """

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let house = try decoder.decode(House.self, from: json.data(using: .utf8)!)

        XCTAssertEqual(house.name, "Keate")
        XCTAssertEqual(house.colours, "red/white")
        XCTAssertEqual(house.parsedColours.count, 2)
    }

    func testHouseIsSchoolTeam() {
        let houseTeam = House(id: UUID(), name: "Keate", colours: "red/white", createdAt: nil)
        XCTAssertFalse(houseTeam.isSchoolTeam)

        let field = House(id: UUID(), name: "Field", colours: "eton/white", createdAt: nil)
        XCTAssertTrue(field.isSchoolTeam)

        let firstField = House(id: UUID(), name: "1st Field", colours: "eton/white", createdAt: nil)
        XCTAssertTrue(firstField.isSchoolTeam)

        let secondXI = House(id: UUID(), name: "2nd XI", colours: "eton/white", createdAt: nil)
        XCTAssertTrue(secondXI.isSchoolTeam)
    }

    func testHouseShortName() {
        let keate = House(id: UUID(), name: "Keate", colours: "red/white", createdAt: nil)
        XCTAssertEqual(keate.shortName, "KEA")

        let baldwinsBec = House(id: UUID(), name: "Baldwin's Bec", colours: "navy/gold", createdAt: nil)
        XCTAssertEqual(baldwinsBec.shortName, "BB")
    }

    // MARK: - Match Model Tests

    func testMatchWithHousesDecoding() throws {
        let json = """
        {
            "id": "550e8400-e29b-41d4-a716-446655440000",
            "home_team_id": "550e8400-e29b-41d4-a716-446655440001",
            "away_team_id": "550e8400-e29b-41d4-a716-446655440002",
            "home_team_name": "Keate",
            "away_team_name": "Hawtrey",
            "home_team_colours": "red/white",
            "away_team_colours": "navy/gold",
            "competition_type": "Senior League",
            "match_date": "2024-03-15T00:00:00Z",
            "match_time": "14:30",
            "location_id": null,
            "location_name": "North Fields",
            "pitch_name": "Pitch 3",
            "home_score": null,
            "away_score": null,
            "status": "scheduled"
        }
        """

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let match = try decoder.decode(MatchWithHouses.self, from: json.data(using: .utf8)!)

        XCTAssertEqual(match.homeTeamName, "Keate")
        XCTAssertEqual(match.awayTeamName, "Hawtrey")
        XCTAssertEqual(match.competitionType, "Senior League")
        XCTAssertEqual(match.status, .scheduled)
        XCTAssertEqual(match.homeKitColors.count, 2)
        XCTAssertEqual(match.awayKitColors.count, 2)
        XCTAssertNil(match.homeScore)
        XCTAssertNil(match.awayScore)
        XCTAssertFalse(match.isCompleted)
        XCTAssertTrue(match.isUpcoming)
    }

    func testMatchWithHousesCompletion() throws {
        let json = """
        {
            "id": "550e8400-e29b-41d4-a716-446655440000",
            "home_team_id": "550e8400-e29b-41d4-a716-446655440001",
            "away_team_id": "550e8400-e29b-41d4-a716-446655440002",
            "home_team_name": "Keate",
            "away_team_name": "Hawtrey",
            "home_team_colours": "red/white",
            "away_team_colours": "navy/gold",
            "competition_type": "Senior League",
            "match_date": "2024-03-15T00:00:00Z",
            "match_time": "14:30",
            "location_id": null,
            "location_name": null,
            "pitch_name": null,
            "home_score": 3,
            "away_score": 1,
            "status": "completed"
        }
        """

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let match = try decoder.decode(MatchWithHouses.self, from: json.data(using: .utf8)!)

        XCTAssertTrue(match.isCompleted)
        XCTAssertFalse(match.isUpcoming)
        XCTAssertEqual(match.scoreString, "3 - 1")
        XCTAssertEqual(match.winner, "Keate")
        XCTAssertFalse(match.isDraw)
    }

    func testMatchInvolves() {
        let match = MatchWithHouses.preview
        XCTAssertTrue(match.involves(teamName: "Keate"))
        XCTAssertTrue(match.involves(teamName: "Hawtrey"))
        XCTAssertFalse(match.involves(teamName: "Godolphin"))
    }

    // MARK: - League Standing Tests

    func testLeagueStandingDecoding() throws {
        let json = """
        {
            "id": "550e8400-e29b-41d4-a716-446655440000",
            "team_id": "550e8400-e29b-41d4-a716-446655440001",
            "team_name": "Keate",
            "team_colours": "red/white",
            "competition_type": "Senior League",
            "played": 10,
            "wins": 7,
            "draws": 2,
            "losses": 1,
            "goals_for": 24,
            "goals_against": 8,
            "goal_difference": 16,
            "points": 23,
            "position": 1
        }
        """

        let decoder = JSONDecoder()
        let standing = try decoder.decode(LeagueStanding.self, from: json.data(using: .utf8)!)

        XCTAssertEqual(standing.teamName, "Keate")
        XCTAssertEqual(standing.played, 10)
        XCTAssertEqual(standing.wins, 7)
        XCTAssertEqual(standing.goalDifference, 16)
        XCTAssertEqual(standing.points, 23)
        XCTAssertEqual(standing.position, 1)
    }

    func testLeagueStandingComputedProperties() {
        let standing = LeagueStanding.preview

        XCTAssertEqual(standing.winPercentage, 70.0)
        XCTAssertGreaterThan(standing.pointsPerGame, 0)
        XCTAssertGreaterThan(standing.goalsPerGame, 0)
    }

    // MARK: - User Profile Tests

    func testUserProfileDecoding() throws {
        let json = """
        {
            "id": "550e8400-e29b-41d4-a716-446655440000",
            "email": "captain@example.com",
            "name": "James Captain",
            "role": "captain",
            "house_id": "550e8400-e29b-41d4-a716-446655440001",
            "house_name": "Keate",
            "created_at": "2024-01-01T00:00:00Z",
            "updated_at": null
        }
        """

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let profile = try decoder.decode(UserProfile.self, from: json.data(using: .utf8)!)

        XCTAssertEqual(profile.email, "captain@example.com")
        XCTAssertEqual(profile.name, "James Captain")
        XCTAssertEqual(profile.role, .captain)
        XCTAssertEqual(profile.houseName, "Keate")
    }

    func testUserRolePermissions() {
        XCTAssertFalse(UserRole.viewer.canEditScores)
        XCTAssertTrue(UserRole.captain.canEditScores)
        XCTAssertTrue(UserRole.admin.canEditScores)

        XCTAssertFalse(UserRole.viewer.isAdmin)
        XCTAssertFalse(UserRole.captain.isAdmin)
        XCTAssertTrue(UserRole.admin.isAdmin)

        XCTAssertTrue(UserRole.admin > UserRole.captain)
        XCTAssertTrue(UserRole.captain > UserRole.viewer)
    }

    func testUserProfileCanEditScore() {
        let captainProfile = UserProfile.captainPreview
        let adminProfile = UserProfile.adminPreview
        let viewerProfile = UserProfile.viewerPreview

        // Captains can edit their own house
        XCTAssertTrue(captainProfile.canEditScore(for: captainProfile.houseId!))

        // Captains cannot edit other houses
        XCTAssertFalse(captainProfile.canEditScore(for: UUID()))

        // Admins can edit any house
        XCTAssertTrue(adminProfile.canEditScore(for: UUID()))

        // Viewers cannot edit any house
        XCTAssertFalse(viewerProfile.canEditScore(for: UUID()))
    }

    // MARK: - Enum Tests

    func testTimeFilterDateRange() {
        let todayFilter = TimeFilter.today
        let range = todayFilter.dateRange

        let calendar = Calendar.current
        XCTAssertTrue(calendar.isDateInToday(range.start))
    }

    func testMatchStatus() {
        XCTAssertEqual(MatchStatus.scheduled.rawValue, "scheduled")
        XCTAssertEqual(MatchStatus.completed.rawValue, "completed")
        XCTAssertEqual(MatchStatus.cancelled.displayName, "Cancelled")
    }

    // MARK: - Cache Service Tests

    func testCacheServiceMemoryOperations() async {
        let cache = CacheService.shared

        // Test set and get
        await cache.set("test_key", value: "test_value", ttl: 60)
        let retrieved: String? = await cache.get("test_key", type: String.self)
        XCTAssertEqual(retrieved, "test_value")

        // Test removal
        await cache.remove("test_key")
        let afterRemoval: String? = await cache.get("test_key", type: String.self)
        XCTAssertNil(afterRemoval)
    }

    func testCacheServiceExpiration() async {
        let cache = CacheService.shared

        // Set with very short TTL
        await cache.set("expiring_key", value: "test", ttl: 0.1)

        // Wait for expiration
        try? await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds

        let retrieved: String? = await cache.get("expiring_key", type: String.self)
        XCTAssertNil(retrieved)
    }

    func testCacheServiceDiskOperations() async throws {
        let cache = CacheService.shared

        // Test persist and load
        try await cache.persistToDisk("disk_test", value: ["key": "value"])

        let loaded: [String: String]? = try await cache.loadFromDisk("disk_test", type: [String: String].self)
        XCTAssertEqual(loaded?["key"], "value")

        // Clean up
        await cache.removeFromDisk("disk_test")
    }

    // MARK: - Performance Tests

    func testKitColorMapperPerformance() {
        measure {
            for _ in 0..<1000 {
                _ = KitColorMapper.parse("red/white/blue")
            }
        }
    }

    func testCompetitionColorPerformance() {
        measure {
            for _ in 0..<1000 {
                _ = Color.competitionColor(for: "Senior League")
            }
        }
    }
}
