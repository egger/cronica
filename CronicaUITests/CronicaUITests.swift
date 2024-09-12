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

}
