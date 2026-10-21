//
//  healthTimelineServiceTest.swift
//  petpawTests
//
//  Created by Piyumi Imalka on 2026-10-21.
//

import XCTest
@testable import petpaw

class HealthTimelineServiceTests: XCTestCase {

    func testKnownCategories() {
        XCTAssertEqual(categoryFor(reminderType: "vaccine"), .vaccine)
        XCTAssertEqual(categoryFor(reminderType: "meds"), .meds)
        XCTAssertEqual(categoryFor(reminderType: "vet"), .vet)
    }

    func testUnknownCategory() {
        XCTAssertEqual(categoryFor(reminderType: "something-unexpected"), .custom)
    }

    func testCompletedStatus() {
        let now = Date()
        let futureDate = now.addingTimeInterval(3600)

        XCTAssertEqual(statusFor(isCompleted: true, date: futureDate, now: now), .done)
    }

    func testUpcomingStatus() {
        let now = Date()
        let futureDate = now.addingTimeInterval(3600)

        XCTAssertEqual(statusFor(isCompleted: false, date: futureDate, now: now), .upcoming)
    }

    func testOverdueStatus() {
        let now = Date()
        let pastDate = now.addingTimeInterval(-3600)

        XCTAssertEqual(statusFor(isCompleted: false, date: pastDate, now: now), .overdue)
    }

    func testMildConcern() {
        XCTAssertTrue(isConcern(condition: "Mild Concern"))
    }

    func testNormalCondition() {
        XCTAssertFalse(isConcern(condition: "Normal"))
    }
}