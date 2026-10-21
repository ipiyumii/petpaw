//
//  petProfileTest.swift
//  petpawTests
//
//  Created by Piyumi Imalka on 2026-10-21.
//

import XCTest
@testable import petpaw

class PetProfileTests: XCTestCase {

    func makeTestPet(dateOfBirth: Date?) -> Pet {
        return Pet(
            id: "1",
            ownerId: "owner1",
            name: "Buddy",
            species: "Dog",
            breed: nil,
            dateOfBirth: dateOfBirth,
            sex: .male,
            weightKg: 10,
            photoURL: nil
        )
    }

    func testPetAge() {
        let date = Calendar.current.date(byAdding: .year,value: -3,to: Date())!
        let pet = makeTestPet(dateOfBirth: date)

        let age = pet.ageInYears

        XCTAssertEqual(age, 3)
    }

    func testPetAgeWithoutDateOfBirth() {
        let pet = makeTestPet(dateOfBirth: nil)

        let age = pet.ageInYears

        XCTAssertNil(age)
    }

    func testValidWeight() {
        let weight = "4.5"

        let result = PetProfile.parseWeight(weight)

        XCTAssertEqual(result, 4.5)
    }

    func testEmptyWeight() {
        let weight = ""

        let result = PetProfile.parseWeight(weight)

        XCTAssertEqual(result, 0)
    }

    func testInvalidWeight() {
        let weight = "abc"

        let result = PetProfile.parseWeight(weight)

        XCTAssertEqual(result, 0)
    }
}
