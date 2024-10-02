//
//  HomeUITests.swift
//  CronicaUITests
//
//  Created by Moataz Akram on 12/09/2024.
//

import XCTest
@testable import Cronica

final class HomeUITests: XCTestCase {
    var app: XCUIApplication!
    var appNavigator: AppNavigator!

    override func setUp() {
        super.setUp()
        app = XCUIApplication()
        app.launchArguments.append("--mock-data")
        app.launch()
        appNavigator = AppNavigator(app: app)
    }
    
    override func tearDown() {
        app = nil
        appNavigator = nil
        super.tearDown()
    }

    func testFullHomeScreen() {
        appNavigator.navigateToTab(.home)
        
        let navigationHomeTitle = app.navigationBars["Home"].staticTexts["Home"]
        XCTAssertTrue(navigationHomeTitle.exists)
        
        // MARK: Trending section -> do not appear when no internet connection
        let trendingTitle = app.staticTexts["Trending"]
        XCTAssertTrue(trendingTitle.exists)
        let todaySubtitle = app.staticTexts["Today"]
        XCTAssertTrue(todaySubtitle.exists)
        
        let trendingList = app.scrollViews["Trending Horizontal List"]
        XCTAssertTrue(trendingList.exists, "Trending List should appear.")
        
        // MARK: Upcoming section
        let upcomingTitle = app.staticTexts["Up Coming"]
        XCTAssertTrue(upcomingTitle.exists)
        let upcomingSubtitle = app.staticTexts["Coming Soon To Theaters"]
        XCTAssertTrue(upcomingSubtitle.exists)

        let upcomingList = app.scrollViews["Up Coming Horizontal List"]
        if !upcomingList.exists {
            app.swipeUp()
        }
        XCTAssertTrue(upcomingList.exists, "Up Coming List should appear.")
        
        // MARK: Latest Movies section
        let latestMoviesTitle = app.staticTexts["Latest Movies"]
        XCTAssertTrue(latestMoviesTitle.exists)
        let latestMoviesSubtitle = app.staticTexts["Recently Released"]
        XCTAssertTrue(latestMoviesSubtitle.exists)
        
        let latestMoviesList = app.scrollViews["Latest Movies Horizontal List"]
        if !latestMoviesList.exists {
            app.swipeUp()
        }
        XCTAssertTrue(latestMoviesList.exists, "Latest Movies List should appear.")

        // MARK: bottom section
        app.swipeUp()
        let tmdbImage = app.images["PrimaryCompact"].firstMatch
        XCTAssertTrue(tmdbImage.exists)
        let bottomText = app.staticTexts["This product uses the TMDb API but is not endorsed or certified by TMDb."]
        XCTAssertTrue(bottomText.exists)
    }
    
}
