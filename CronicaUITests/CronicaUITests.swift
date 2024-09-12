//
//  CronicaUITests.swift
//  CronicaUITests
//
//  Created by Moataz Akram on 08/09/2024.
//

@testable import Cronica
import XCTest

final class CronicaUITests: XCTestCase {
    var app: XCUIApplication!
    var appNavigator: AppNavigator!
    override func setUp() {
        super.setUp()
        app = XCUIApplication()
        app.launch()
        appNavigator = AppNavigator(app: app)
    }
    
    override func tearDown() {
        app = nil
        appNavigator = nil
        super.tearDown()
    }
    
    func testHomeScreen() {
        appNavigator.navigateToTab(.home)
        
        let homeViewPredicate = NSPredicate(format: "identifier == 'Home View'")
        let homeView = app.otherElements.containing(homeViewPredicate).firstMatch

        let exists = homeView.waitForExistence(timeout: 1)
        XCTAssertTrue(exists, "Home View should appear.")
    }
    
    func testDiscoverScreen() {
        appNavigator.navigateToTab(.explore)
        
        let homeViewPredicate = NSPredicate(format: "identifier == 'Discover View'")
        let homeView = app.otherElements.containing(homeViewPredicate).firstMatch

        let exists = homeView.waitForExistence(timeout: 1)
        XCTAssertTrue(exists, "Discover View should appear.")
    }

    func testWatchListScreen() {
        appNavigator.navigateToTab(.watchlist)
        
        let watchlistViewPredicate = NSPredicate(format: "identifier == 'Watchlist View'")
        let watchlistView = app.otherElements.containing(watchlistViewPredicate).firstMatch

        let exists = watchlistView.waitForExistence(timeout: 1)
        XCTAssertTrue(exists, "Watchlist View should appear.")
    }

    func testSearchScreen() {
        appNavigator.navigateToTab(.search)
        
        let searchViewPredicate = NSPredicate(format: "identifier == 'Search View'")
        let searchView = app.otherElements.containing(searchViewPredicate).firstMatch

        let exists = searchView.waitForExistence(timeout: 1)
        XCTAssertTrue(exists, "Search View should appear.")
    }

    func testSettingsScreen() {
        appNavigator.navigateToTab(.settings)
        
        let settingsViewPredicate = NSPredicate(format: "identifier == 'Settings View'")
        let settingsView = app.otherElements.containing(settingsViewPredicate).firstMatch

        let exists = settingsView.waitForExistence(timeout: 1)
        XCTAssertTrue(exists, "Settings View should appear.")
    }

    func testNotificationListScreen() {
        appNavigator.navigateToTab(.notifications)
        
        let notificationListViewPredicate = NSPredicate(format: "identifier == 'Notification List View'")
        let notificationListView = app.otherElements.containing(notificationListViewPredicate).firstMatch

        let exists = notificationListView.waitForExistence(timeout: 1)
        XCTAssertTrue(exists, "Notification List should appear.")
    }

}
