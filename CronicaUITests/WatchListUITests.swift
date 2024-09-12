//
//  WatchListUITests.swift
//  CronicaUITests
//
//  Created by Moataz Akram on 13/09/2024.
//

import XCTest
@testable import Cronica

final class WatchListUITests: XCTestCase {
    var app: XCUIApplication!
    var appNavigator: AppNavigator!

    override func setUp() {
        super.setUp()
        app = XCUIApplication()
        app.launchArguments.append("--delete-cache")
        app.launch()
        appNavigator = AppNavigator(app: app)
    }
    
    override func tearDown() {
        appNavigator = nil
        app = nil
        super.tearDown()
    }

    func testWatchListFullScreen() {
        appNavigator.navigateToTab(.home)
        app.scrollViews["Trending Horizontal List"].buttons["Zack Snyder's Justice League"].tap()

        let addRemoveButton = app.buttons["Add Remove Button"]
        XCTAssertTrue(addRemoveButton.exists)
        let addRemoveButtonIcon = app.images["Add Remove Button Icon"]
        if addRemoveButtonIcon.label == "Add" {
            addRemoveButtonIcon.tap()
        }

        appNavigator.navigateToTab(.watchlist)
        let app = XCUIApplication()
        let watchlistNavigationBar = app.navigationBars["Watchlist"]
        let listDropDown = watchlistNavigationBar.images["Go Down"]
        listDropDown.tap()
        app.buttons["New List"].tap()
        
        let listTitleTextField = app.textFields["ListTitleTextField"]
        XCTAssertTrue(listTitleTextField.exists)
        listTitleTextField.tap()
        listTitleTextField.typeText("Watch Again")
        let listDescriptionTextField = app.textFields["ListDescriptionTextField"]
        XCTAssertTrue(listDescriptionTextField.exists)

        let createButton = app.buttons["CreateNewListButton"]
        createButton.tap()
        
        app.navigationBars["Watch Again"].images["Go Down"].tap()
        let watchAgainList = app.collectionViews.children(matching: .cell).element(boundBy: 2).buttons["Watch Again, 0 items"]
        watchAgainList.swipeLeft()
        app.buttons["Edit"].tap()
        let deleteButton = app.buttons["DeleteListButton"]
        deleteButton.tap()
        let confirmButton = app.buttons["ConfirmDeleteButton"]
        confirmButton.tap()
    }
}
