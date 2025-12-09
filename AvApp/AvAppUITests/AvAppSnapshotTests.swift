//
//  AvAppSnapshotTests.swift
//  AvApp
//
//  Created by Hasan Zaidi on 12/8/25.
//

import XCTest

class AvAppSnapshotTests: XCTestCase {

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    func test_flightList_aircraftDetail_and_map() {
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()

        // 01 – Flight list (whatever your initial screen is)
        snapshot("01-Flight-List")

        // If your flight list is on a tab, e.g. "Flights",
        // uncomment and adjust this:
//        app.tabBars.buttons["Flights"].tap()

        // 02 – Tap first flight to open AircraftDetailView
        let firstFlight = app.cells.matching(identifier: "flight-row").firstMatch
        XCTAssertTrue(firstFlight.waitForExistence(timeout: 5), "No flight row found")
        firstFlight.tap()
        snapshot("02-Aircraft-Detail")

        // 03 – Scroll to map and capture live track (if available)
        let detailList = app.tables["aircraft-detail-list"]
        if detailList.waitForExistence(timeout: 5) {
            // Scroll until map appears or stop after some swipes
            var foundMap = false
            for _ in 0..<6 {
                if app.otherElements["track-map"].exists {
                    foundMap = true
                    break
                }
                detailList.swipeUp()
            }

            if foundMap {
                snapshot("03-Track-Map")
            } else {
                // fallback screenshot without map
                snapshot("03-Track-Map-Unavailable")
            }
        }
    }
}
