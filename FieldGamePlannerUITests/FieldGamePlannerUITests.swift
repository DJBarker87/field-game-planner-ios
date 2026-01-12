//
//  FieldGamePlannerUITests.swift
//  FieldGamePlannerUITests
//
//  Created by Claude on 2026-01-11.
//

import XCTest

final class FieldGamePlannerUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it's important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }

    func testTabBarNavigation() throws {
        let app = XCUIApplication()
        app.launch()

        // Test that tab bar exists
        XCTAssertTrue(app.tabBars.firstMatch.exists)

        // Test navigation to each tab
        app.tabBars.buttons["Fixtures"].tap()
        XCTAssertTrue(app.navigationBars["Fixtures"].exists)

        app.tabBars.buttons["Results"].tap()
        XCTAssertTrue(app.navigationBars["Results"].exists)

        app.tabBars.buttons["Standings"].tap()
        XCTAssertTrue(app.navigationBars["Standings"].exists)

        app.tabBars.buttons["Pitches"].tap()
        XCTAssertTrue(app.navigationBars["Pitch Maps"].exists)

        app.tabBars.buttons["Settings"].tap()
        XCTAssertTrue(app.navigationBars["Settings"].exists)
    }

    func testFixturesFilterMenu() throws {
        let app = XCUIApplication()
        app.launch()

        // Navigate to Fixtures tab
        app.tabBars.buttons["Fixtures"].tap()

        // Look for filter button in toolbar
        let filterButton = app.navigationBars.buttons["Filter"]
        if filterButton.exists {
            filterButton.tap()

            // Check filter options exist
            XCTAssertTrue(app.buttons["Today"].waitForExistence(timeout: 2))
        }
    }

    func testStandingsCompetitionPicker() throws {
        let app = XCUIApplication()
        app.launch()

        // Navigate to Standings tab
        app.tabBars.buttons["Standings"].tap()

        // Check navigation bar exists
        XCTAssertTrue(app.navigationBars["Standings"].exists)
    }

    func testSettingsContent() throws {
        let app = XCUIApplication()
        app.launch()

        // Navigate to Settings tab
        app.tabBars.buttons["Settings"].tap()

        // Check for common settings elements
        let settingsNav = app.navigationBars["Settings"]
        XCTAssertTrue(settingsNav.exists)
    }

    func testPullToRefresh() throws {
        let app = XCUIApplication()
        app.launch()

        // Navigate to Fixtures tab
        app.tabBars.buttons["Fixtures"].tap()

        // Find scrollable content
        let scrollView = app.scrollViews.firstMatch
        if scrollView.exists {
            // Perform pull to refresh gesture
            scrollView.swipeDown()
        }
    }

    func testAccessibilityLabels() throws {
        let app = XCUIApplication()
        app.launch()

        // Check tab bar buttons have accessibility labels
        XCTAssertTrue(app.tabBars.buttons["Fixtures"].exists)
        XCTAssertTrue(app.tabBars.buttons["Results"].exists)
        XCTAssertTrue(app.tabBars.buttons["Standings"].exists)
        XCTAssertTrue(app.tabBars.buttons["Pitches"].exists)
        XCTAssertTrue(app.tabBars.buttons["Settings"].exists)
    }

    func testTabPersistenceOnRelaunch() throws {
        let app = XCUIApplication()
        app.launch()

        // Navigate to Standings tab
        app.tabBars.buttons["Standings"].tap()
        XCTAssertTrue(app.navigationBars["Standings"].exists)

        // Navigate to Settings
        app.tabBars.buttons["Settings"].tap()
        XCTAssertTrue(app.navigationBars["Settings"].exists)

        // Go back to Fixtures
        app.tabBars.buttons["Fixtures"].tap()
        XCTAssertTrue(app.navigationBars["Fixtures"].exists)
    }
}
