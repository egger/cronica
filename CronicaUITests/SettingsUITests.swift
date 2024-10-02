//
//  SettingsUITests.swift
//  CronicaUITests
//
//  Created by Moataz Akram on 13/09/2024.
//

import XCTest
@testable import Cronica

final class SettingsUITests: XCTestCase {
    var app: XCUIApplication! = XCUIApplication()
    var appNavigator: AppNavigator!

    override func setUp() {
        super.setUp()
        app = XCUIApplication()
        app.launch()
        appNavigator = AppNavigator(app: app)
    }
    
    override func tearDown() {
        appNavigator = nil
        app = nil
        super.tearDown()
    }
    
    func testSettingsFullScreen() {
        appNavigator.navigateToTab(.settings)
        // MARK: General Section
        XCTAssertTrue(app.staticTexts["GENERAL"].exists)
        XCTAssertTrue(app.staticTexts["Behavior Tab"].exists)
        XCTAssertTrue(app.images["hand.tap Icon"].exists)
        XCTAssertTrue(app.staticTexts["Appearance Tab"].exists)
        XCTAssertTrue(app.images["paintbrush Icon"].exists)
        XCTAssertTrue(app.staticTexts["Notification Tab"].exists)
        XCTAssertTrue(app.images["bell Icon"].exists)

        // MARK: App Features Section
        XCTAssertTrue(app.staticTexts["APP FEATURES"].exists)
        XCTAssertTrue(app.staticTexts["Watchlist Tab"].exists)
        XCTAssertTrue(app.images["rectangle.on.rectangle Icon"].exists)
        XCTAssertTrue(app.staticTexts["Season & Up Next Tab"].exists)
        XCTAssertTrue(app.images["tv Icon"].exists)
        XCTAssertTrue(app.staticTexts["Watch Provider Tab"].exists)
        XCTAssertTrue(app.images["globe Icon"].exists)

        // MARK: Support & About Section
        XCTAssertTrue(app.staticTexts["SUPPORT & ABOUT"].exists)
        XCTAssertTrue(app.staticTexts["Feedback Tab"].exists)
        XCTAssertTrue(app.images["envelope.fill Icon"].exists)
        XCTAssertTrue(app.staticTexts["Privacy Policy Tab"].exists)
        XCTAssertTrue(app.images["hand.raised Icon"].exists)
        XCTAssertTrue(app.staticTexts["Tip Jar Tab"].exists)
        XCTAssertTrue(app.images["heart Icon"].exists)
        XCTAssertTrue(app.staticTexts["About Tab"].exists)
        XCTAssertTrue(app.images["info.circle Icon"].exists)
    }

}
