//
//  AvAppUITests.swift
//  AvAppUITests
//
//  Created by Hasan Zaidi on 7/31/25.
//

import XCTest

final class AvAppUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
    
//    func testScreenshots() {
//        let app = XCUIApplication()
//        setupSnapshot(app)
//        app.launch()
//        
//        // Screen 1
//        snapshot("01-HomeScreen")
//        
//        // Example navigation
//        app.buttons["FlightsTab"].tap()
//        snapshot("02-FlightsScreen")
//        
//        app.buttons["MapTab"].tap()
//        snapshot("03-MapScreen")
//    }
    
}

extension XCTestCase {
    /// Minimal setup helper to make screenshot tests consistent.
    /// Mirrors the typical Fastlane `setupSnapshot` intent without requiring the dependency.
    func setupSnapshot(_ app: XCUIApplication) {
        // Add arguments to help keep output consistent and distinguish UI testing runs.
        app.launchArguments += [
            "-ui_testing_screenshots"
        ]
        // Optionally pin language/locale for consistency (uncomment if needed):
        // app.launchArguments += ["-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
    }

    /// Takes a screenshot and adds it as an attachment that is always kept in test results.
    /// - Parameter name: The logical name for the screenshot attachment.
    func snapshot(_ name: String) {
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
