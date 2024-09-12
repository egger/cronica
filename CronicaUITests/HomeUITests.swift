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
    
    override func setUp() {
        super.setUp()
        app = XCUIApplication()
        app.launch()
    }
    
    override func tearDown() {
        app = nil
        super.tearDown()
    }

    func testFullHomeScreen() {
        CronicaUITests().dismissWelcomeScreenIfAppearingOnLaunch() // TODO: refactor these 2 lines
        CronicaUITests().navigateToTab(.home)
        
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
            scrollUp()
        }
        XCTAssertTrue(upcomingList.exists, "Up Coming List should appear.")
        
        // MARK: Latest Movies section
        let latestMoviesTitle = app.staticTexts["Latest Movies"]
        XCTAssertTrue(latestMoviesTitle.exists)
        let latestMoviesSubtitle = app.staticTexts["Recently Released"]
        XCTAssertTrue(latestMoviesSubtitle.exists)
        
        let latestMoviesList = app.scrollViews["Latest Movies Horizontal List"]
        if !latestMoviesList.exists {
            scrollUp()
        }
        XCTAssertTrue(latestMoviesList.exists, "Latest Movies List should appear.")

        // MARK: bottom section
        scrollUp()
        let tmdbImage = app.images["PrimaryCompact"].firstMatch
        XCTAssertTrue(tmdbImage.exists)
        let bottomText = app.staticTexts["This product uses the TMDb API but is not endorsed or certified by TMDb."]
        XCTAssertTrue(bottomText.exists)

        return

        
    }
    
    
    func scrollUp() {
        let homeViewPredicate = NSPredicate(format: "identifier == 'Home View'")
        let homeView = app.otherElements.containing(homeViewPredicate).firstMatch
        homeView.swipeUp()
//        let startPoint = homeView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.9))
//        let endPoint = homeView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.75))
//        startPoint.press(forDuration: 0.01, thenDragTo: endPoint)
    }
}
