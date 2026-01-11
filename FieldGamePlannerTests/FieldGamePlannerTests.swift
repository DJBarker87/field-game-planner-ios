//
//  FieldGamePlannerTests.swift
//  FieldGamePlannerTests
//
//  Created by Claude on 2026-01-11.
//

import XCTest
@testable import FieldGamePlanner

final class FieldGamePlannerTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testColorSystem() throws {
        // Test Eton Green color exists
        let etonGreen = Color.etonGreen
        XCTAssertNotNil(etonGreen)
    }

    func testKitColorMapper() throws {
        // Test parsing kit colors
        let colors = KitColorMapper.parse("red/white")
        XCTAssertEqual(colors.count, 2)

        let singleColor = KitColorMapper.parse("blue")
        XCTAssertEqual(singleColor.count, 1)

        let emptyColors = KitColorMapper.parse("")
        XCTAssertEqual(emptyColors.count, 1) // Default gray
    }

    func testCompetitionColors() throws {
        // Test competition color mapping
        let seniorColor = Color.competitionColor(for: "Senior League")
        let juniorColor = Color.competitionColor(for: "Junior League")
        XCTAssertNotEqual(seniorColor, juniorColor)
    }

    func testMatchModel() throws {
        // Test Match model
        let match = Match.preview
        XCTAssertFalse(match.homeTeam.isEmpty)
        XCTAssertFalse(match.awayTeam.isEmpty)
        XCTAssertFalse(match.competition.isEmpty)
    }

    func testStandingModel() throws {
        // Test Standing model
        let standing = Standing.preview
        XCTAssertEqual(standing.goalDifference, standing.goalsFor - standing.goalsAgainst)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
            _ = KitColorMapper.parse("red/white/blue")
        }
    }
}

// Import SwiftUI for Color in tests
import SwiftUI
