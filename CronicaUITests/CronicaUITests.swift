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

}
