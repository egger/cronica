//
//  ItemContentDetailsUITests.swift
//  CronicaUITests
//
//  Created by Moataz Akram on 12/09/2024.
//

import XCTest
@testable import Cronica

final class ItemContentDetailsUITests: XCTestCase {
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
        appNavigator = nil
        app = nil
        super.tearDown()
    }
    
    func navigateToItemContentDetails() {
        app.scrollViews["Trending Horizontal List"].buttons["Zack Snyder's Justice League"].tap()
    }
    
    func testItemContentDetailsFullScreen() {
        appNavigator.navigateToTab(.home)
        navigateToItemContentDetails()

        //MARK: Head Section
        headSectionChecks()

        //MARK: Buttons Section
        buttonsSectionChecks()
        
        //MARK: About Section
        aboutSectionChecks()
        app.swipeUp(velocity: .slow)
        
        //MARK: Where To Watch Section
        whereToWatchSectionChecks()
        
        //MARK: Trailers Section
        trailersSectionChecks()
        app.swipeUp(velocity: .slow)

        //MARK: Cast Section
        castSectionChecks()
        
        //MARK: Recommendations Section
        recommendationsSectionChecks()
        app.swipeUp(velocity: .slow)

        //MARK: Information Section
        informationSectionChecks()
    }
    
    func headSectionChecks() {
        let itemTitle = app.staticTexts["Item Title"]
        XCTAssertEqual(itemTitle.label, "Zack Snyder's Justice League")
        let itemGenres = app.staticTexts["Item Genres"]
        XCTAssertEqual(itemGenres.label, "Action, Adventure, Fantasy")
        let itemInfo = app.staticTexts["Item Info"]
        XCTAssertEqual(itemInfo.label, "18 Mar 2021 • 4h 2m")
    }
    
    func buttonsSectionChecks() {
        let listButton = app.buttons["List Button"]
        XCTAssertTrue(listButton.exists)
        
        let addRemoveButton = app.buttons["Add Remove Button"]
        XCTAssertTrue(addRemoveButton.exists)
        let addRemoveButtonIcon = app.images["Add Remove Button Icon"]
        if addRemoveButtonIcon.label == "Remove" {
            addRemoveButtonIcon.tap()
        }
        XCTAssertTrue(addRemoveButtonIcon.exists)
        XCTAssertEqual(addRemoveButtonIcon.label, "Add")
        addRemoveButtonIcon.tap()
        XCTAssertEqual(addRemoveButtonIcon.label, "Remove")
        
        addRemoveButtonIcon.tap()
        XCTAssertEqual(addRemoveButtonIcon.label, "Add")

        let watchedButton = app.buttons["Watch Button"]
        XCTAssertTrue(watchedButton.exists)
        let watchedButtonIcon = app.images["Watch Button Icon"]
        XCTAssertTrue(watchedButtonIcon.exists)
        XCTAssertEqual(watchedButtonIcon.label, "rectangle.badge.checkmark")
        watchedButton.tap()
        XCTAssertEqual(watchedButtonIcon.label, "rectangle.badge.checkmark.fill")
        watchedButton.tap()
        XCTAssertEqual(watchedButtonIcon.label, "rectangle.badge.checkmark")
    }
    
    func aboutSectionChecks() {
        let aboutText = app.staticTexts["About Text"]
        XCTAssertEqual(aboutText.label, "About")
        let aboutDescription = app.staticTexts["Overview Text"]
        XCTAssertEqual(aboutDescription.label, "Determined to ensure Superman's ultimate sacrifice was not in vain, Bruce Wayne aligns forces with Diana Prince with plans to recruit a team of metahumans to protect the world from an approaching threat of catastrophic proportions.")

    }
    
    func whereToWatchSectionChecks() {
        let whereToWatchText = app.staticTexts["Where to Watch"]
        XCTAssertTrue(whereToWatchText.exists)
        let providedByText = app.staticTexts["Provided by JustWatch"]
        XCTAssertTrue(providedByText.exists)
        let providersList = app.otherElements["Watch Providers List"]
        XCTAssertTrue(providersList.exists)
        let appleTVProvider = app.buttons["Apple TV provider"]
        XCTAssertTrue(appleTVProvider.exists)
        let maxProvider = app.buttons["Max provider"]
        XCTAssertTrue(maxProvider.exists)

    }
    
    func trailersSectionChecks() {
        let trailersText = app.staticTexts["Trailers"]
        XCTAssertTrue(trailersText.exists)
        let trailersList = app.scrollViews["Trailers List"]
        XCTAssertTrue(trailersList.exists)
        let firstTrailer = app.staticTexts["Official UK Trailer"]
        XCTAssertTrue(firstTrailer.exists)
    }
    
    func castSectionChecks() {
        let castTitle = app.staticTexts["Cast & Crew"]
        XCTAssertTrue(castTitle.exists)
        let castList = app.scrollViews["Cast List"]
        XCTAssertTrue(castList.exists)
        let firstCard = app.buttons["Ben Affleck Card"]
        XCTAssertTrue(firstCard.exists)
    }
    
    func recommendationsSectionChecks() {
        let recommendationsTitle = app.staticTexts["Recommendations"]
        XCTAssertTrue(recommendationsTitle.exists)
        
        let recommendationsList = app.scrollViews["Recommendations Horizontal List"]
        XCTAssertTrue(recommendationsList.exists, "Recommendations List should appear.")

        let recommendationTitle = app.staticTexts["Justice League"]
        XCTAssertTrue(recommendationTitle.exists)
        
        let recommendationCard = app.buttons["Justice League Card"]
        XCTAssertTrue(recommendationCard.exists)
    }
    
    func informationSectionChecks() {
        let informationSection = app.otherElements["Information Section"]
        XCTAssertTrue(informationSection.exists)
        XCTAssertTrue(app.staticTexts["Original Title"].exists)
        XCTAssertTrue(app.staticTexts["Zack Snyder's Justice League"].exists)
        XCTAssertTrue(app.staticTexts["Run Time"].exists)
        XCTAssertTrue(app.staticTexts["4 hours, 2 minutes"].exists)
        XCTAssertTrue(app.staticTexts["Release Date"].exists)
        XCTAssertTrue(app.staticTexts["18 Mar 2021"].exists)
        XCTAssertTrue(app.staticTexts["8.1/10"].exists)
        XCTAssertTrue(app.staticTexts["Status"].exists)
        XCTAssertTrue(app.staticTexts["Released"].exists)
        XCTAssertTrue(app.staticTexts["Genres"].exists)
        XCTAssertTrue(app.staticTexts["Action, Adventure, Fantasy"].exists)
        XCTAssertTrue(app.staticTexts["Region of Origin"].exists)
        XCTAssertTrue(app.staticTexts["United States of America"].exists)
        XCTAssertTrue(app.staticTexts["Production Companies"].exists)
        XCTAssertTrue(app.staticTexts["Warner Bros. Pictures, The Stone Quarry, Atlas Entertainment, Access Entertainment, Dune Entertainment, DC Films"].exists)
    }
}
