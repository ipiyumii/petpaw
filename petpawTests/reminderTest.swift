//
//  reminderTest.swift
//  petpawTests
//
//  Created by Piyumi Imalka on 2026-10-17.
//

import XCTest
@testable import petpaw

class ReminderTest: XCTestCase {

    func testIcon_WhenTypeIsMeds_ReturnsPillsIcon() {
        let result = ReminderUI.icon(for: "meds")

        XCTAssertEqual(result, "pills.fill")
    }

    func testIcon_WhenTypeIsVaccine_ReturnsVaccineIcon() {
        let result = ReminderUI.icon(for: "vaccine")

        XCTAssertEqual(result, "cross.vial.fill")
    }

    func testIcon_WhenTypeIsVet_ReturnsCalendarIcon() {
        let result = ReminderUI.icon(for: "vet")
        XCTAssertEqual(result, "calendar")
    }

    func testIcon_WhenTypeIsUnknown_ReturnsDocumentIcon() {
        let result = ReminderUI.icon(for: "custom")

        XCTAssertEqual(result, "doc.text.fill")
    }

    func testIconColor_WhenTypeIsMeds_ReturnsWarningColor() {
        let screen = ReminderUI()
        let result = screen.iconColor(for: "meds")

        XCTAssertEqual(result, PetPawColors.warning)
    }
}
