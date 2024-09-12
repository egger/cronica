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
    
    override func setUp() {
        super.setUp()
        app = XCUIApplication()
        app.launch()
    }
    
    override func tearDown() {
        app = nil
        super.tearDown()
    }

    func NavigateToHomeTab() {
        let tabBar = app.tabBars["Tab Bar"]
        let homeButton = tabBar.buttons["Home"]
        homeButton.tap()
    }
    
    func navigateToTab(_ tab: Screens) {
        let tabBar = app.tabBars["Tab Bar"]
        
        switch tab {
        case .home:
            tabBar.buttons["Home"].tap()
        case .explore:
            tabBar.buttons["Discover"].tap()
        case .watchlist:
            tabBar.buttons["Watchlist"].tap()
        case .search:
            tabBar.buttons["Search"].tap()
        case .notifications:
            NavigateToHomeTab()
            app.buttons["Notifications"].tap()
        case .settings:
            NavigateToHomeTab()
            app.buttons["Settings"].tap()
        }
    }

    func dismissWelcomeScreenIfAppearingOnLaunch() {
        let welcomeViewPredicate = NSPredicate(format: "identifier == 'Welcome View'")
        let welcomeView = app.otherElements.containing(welcomeViewPredicate).firstMatch
        let continueButton = welcomeView.buttons["Continue"]
        if continueButton.exists {
            continueButton.tap()
        }
    }
    
    func testHomeScreen() {
        dismissWelcomeScreenIfAppearingOnLaunch()
        navigateToTab(.home)
        
        let homeViewPredicate = NSPredicate(format: "identifier == 'Home View'")
        let homeView = app.otherElements.containing(homeViewPredicate).firstMatch

        let exists = homeView.waitForExistence(timeout: 1)
        XCTAssertTrue(exists, "Home View should appear.")
    }
    
    func testDiscoverScreen() {
        dismissWelcomeScreenIfAppearingOnLaunch()
        navigateToTab(.explore)
        
        let homeViewPredicate = NSPredicate(format: "identifier == 'Discover View'")
        let homeView = app.otherElements.containing(homeViewPredicate).firstMatch

        let exists = homeView.waitForExistence(timeout: 1)
        XCTAssertTrue(exists, "Discover View should appear.")
    }

    func testWatchListScreen() {
        dismissWelcomeScreenIfAppearingOnLaunch()
        navigateToTab(.watchlist)
        
        let watchlistViewPredicate = NSPredicate(format: "identifier == 'Watchlist View'")
        let watchlistView = app.otherElements.containing(watchlistViewPredicate).firstMatch

        let exists = watchlistView.waitForExistence(timeout: 1)
        XCTAssertTrue(exists, "Watchlist View should appear.")
    }

    func testSearchScreen() {
        dismissWelcomeScreenIfAppearingOnLaunch()
        navigateToTab(.search)
        
        let searchViewPredicate = NSPredicate(format: "identifier == 'Search View'")
        let searchView = app.otherElements.containing(searchViewPredicate).firstMatch

        let exists = searchView.waitForExistence(timeout: 1)
        XCTAssertTrue(exists, "Search View should appear.")
    }

    func testSettingsScreen() {
        dismissWelcomeScreenIfAppearingOnLaunch()
        navigateToTab(.settings)
        
        let settingsViewPredicate = NSPredicate(format: "identifier == 'Settings View'")
        let settingsView = app.otherElements.containing(settingsViewPredicate).firstMatch

        let exists = settingsView.waitForExistence(timeout: 1)
        XCTAssertTrue(exists, "Settings View should appear.")
    }

    func testNotificationListScreen() {
        dismissWelcomeScreenIfAppearingOnLaunch()
        navigateToTab(.notifications)
        
        let notificationListViewPredicate = NSPredicate(format: "identifier == 'Notification List View'")
        let notificationListView = app.otherElements.containing(notificationListViewPredicate).firstMatch

        let exists = notificationListView.waitForExistence(timeout: 1)
        XCTAssertTrue(exists, "Notification List should appear.")
    }

}
