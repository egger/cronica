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
        
        
        let trendingListPredicate = NSPredicate(format: "identifier == 'Trending Horizontal List'")
        let trendingList = app.otherElements.containing(trendingListPredicate).firstMatch
        let trendingListExists = trendingList.waitForExistence(timeout: 1)
        XCTAssertTrue(trendingListExists, "Trending List should appear.")
        
        // MARK: Upcoming section
        let upcomingTitle = app.staticTexts["Up Coming"]
        XCTAssertTrue(upcomingTitle.exists)
        let upcomingSubtitle = app.staticTexts["Coming Soon To Theaters"]
        XCTAssertTrue(upcomingSubtitle.exists)

        let upcomingListPredicate = NSPredicate(format: "identifier == 'Up Coming Horizontal List'")
        let upcomingList = app.otherElements.containing(upcomingListPredicate).firstMatch
        let upcomingListExists = upcomingList.waitForExistence(timeout: 1)
        if !upcomingListExists { //TODO: extract scroll to helper function
            scrollUp()
        }
        XCTAssertTrue(upcomingListExists, "Up Coming List should appear.")
        
        // MARK: Latest Movies section
        let latestMoviesTitle = app.staticTexts["Latest Movies"]
        XCTAssertTrue(latestMoviesTitle.exists)
        let latestMoviesSubtitle = app.staticTexts["Recently Released"]
        XCTAssertTrue(latestMoviesSubtitle.exists)
        
        let latestMoviesListPredicate = NSPredicate(format: "identifier == 'Latest Movies Horizontal List'")
        let latestMoviesList = app.otherElements.containing(latestMoviesListPredicate).firstMatch
        let latestMoviesListExists = latestMoviesList.waitForExistence(timeout: 1)
        if !upcomingListExists { //TODO: extract scroll to helper function
            scrollUp()
        }
        XCTAssertTrue(latestMoviesListExists, "Up Coming View should appear.")

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
        let exists = homeView.waitForExistence(timeout: 1)
        homeView.swipeUp()
    }
}
