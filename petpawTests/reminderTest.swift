//
//  reminderTest.swift
//  petpawTests
//
//  Created by Piyumi Imalka on 2026-10-17.
//

import XCTest
@testable import petpaw

class ReminderTest: XCTestCase {

    func testMedsIcon() {
        let screen = ReminderUI()
        let result = screen.icon(for: "meds")

        XCTAssertEqual(result, "pills.fill")
    }

    func testVaccineIcon() {
        let screen = ReminderUI()
        let result = screen.icon(for: "vaccine")

        XCTAssertEqual(result, "cross.vial.fill")
    }

    func testVetIcon() {
        let screen = ReminderUI()
        let result = screen.icon(for: "vet")

        XCTAssertEqual(result, "calendar")
    }

    func testCustomIcon() {
        let screen = ReminderUI()
        let result = screen.icon(for: "custom")

        XCTAssertEqual(result, "doc.text.fill")
    }

    func testMedsIconColor() {
        let screen = ReminderUI()
        let result = screen.iconColor(for: "meds")

        XCTAssertEqual(result, PetPawColors.warning)
    }


    func testCombineDateAndTime() {
        let calendar = Calendar.current

        let date = calendar.date(from: DateComponents(
            year: 2025,
            month: 5,
            day: 13
        ))!

        let time = calendar.date(from: DateComponents(
            hour: 14,
            minute: 30
        ))!

        let hour = calendar.component(.hour, from: time)
        let minute = calendar.component(.minute, from: time)

        let result = calendar.date(
            bySettingHour: hour,
            minute: minute,
            second: 0,
            of: date
        )!

        XCTAssertEqual(calendar.component(.year, from: result), 2025)
        XCTAssertEqual(calendar.component(.month, from: result), 5)
        XCTAssertEqual(calendar.component(.day, from: result), 13)
        XCTAssertEqual(calendar.component(.hour, from: result), 14)
        XCTAssertEqual(calendar.component(.minute, from: result), 30)
    }

}
