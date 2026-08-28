import XCTest

final class AvAppFailurePathUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func test_networkError_showsRetryAlert() {
        let app = XCUIApplication()
        app.launchArguments += ["-ui_testing", "-ui_testing_network_error"]
        app.launch()

        let alert = app.alerts["Something went wrong"]
        XCTAssertTrue(alert.waitForExistence(timeout: 5), "Expected a network error alert")
        XCTAssertTrue(alert.staticTexts["Simulated network error"].exists)
        XCTAssertTrue(alert.buttons["Retry"].exists)
        XCTAssertTrue(alert.buttons["Dismiss"].exists)
    }

    @MainActor
    func test_emptyRegistration_showsLookupError() {
        let app = XCUIApplication()
        app.launchArguments += ["-ui_testing", "-ui_testing_empty_registration"]
        app.launch()

        let firstFlight = app.descendants(matching: .any).matching(identifier: "flight-row").firstMatch
        XCTAssertTrue(firstFlight.waitForExistence(timeout: 5), "No flight row found")
        firstFlight.tap()

        let error = app.staticTexts["aircraft-error-message"]
        XCTAssertTrue(error.waitForExistence(timeout: 5), "Expected empty-registration error")
        XCTAssertEqual(error.label, "This flight has no aircraft registration to look up.")
    }
}
