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
}
