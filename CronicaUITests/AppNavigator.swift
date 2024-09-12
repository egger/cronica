//
//  AppNavigator.swift
//  CronicaUITests
//
//  Created by Moataz Akram on 13/09/2024.
//

import XCTest
@testable import Cronica

final class AppNavigator {
    let app: XCUIApplication

    init(app: XCUIApplication) {
        self.app = app
    }
    
    func navigateToTab(_ tab: Screens) {
        dismissWelcomeScreenIfAppearingOnLaunch()
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
            navigateToHomeTab()
            app.buttons["Notifications"].tap()
        case .settings:
            navigateToHomeTab()
            app.buttons["Settings"].tap()
        }
    }
    
    private func navigateToHomeTab() {
        let tabBar = app.tabBars["Tab Bar"]
        tabBar.buttons["Home"].tap()
    }
    
    func dismissWelcomeScreenIfAppearingOnLaunch() {
        let welcomeViewPredicate = NSPredicate(format: "identifier == 'Welcome View'")
        let welcomeView = app.otherElements.containing(welcomeViewPredicate).firstMatch
        let continueButton = welcomeView.buttons["Continue"]
        if continueButton.exists {
            continueButton.tap()
        }
    }

}
