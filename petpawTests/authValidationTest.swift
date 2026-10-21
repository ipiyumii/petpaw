//
//  authValidationTest.swift
//  petpawTests
//
//  Created by Piyumi Imalka on 2026-10-21.
//

import XCTest
@testable import petpaw

class AuthValidationTests: XCTestCase {

    let authViewModel = AuthViewModel()

    func testValidPassword() {
        let password = "Abcde123!"

        let result = authViewModel.isPasswordValid(password)

        XCTAssertTrue(result)
    }

    func testPasswordTooShort() {
        let password = "Ab1!"

        let result = authViewModel.isPasswordValid(password)

        XCTAssertFalse(result)
    }

    func testPasswordWithoutUppercase() {
        let password = "abcde123!"

        let result = authViewModel.isPasswordValid(password)

        XCTAssertFalse(result)
    }

    func testPasswordWithoutLowercase() {
        let password = "ABCDE123!"

        let result = authViewModel.isPasswordValid(password)

        XCTAssertFalse(result)
    }

    func testPasswordWithoutNumber() {
        let password = "Abcdefgh!"

        let result = authViewModel.isPasswordValid(password)

        XCTAssertFalse(result)
    }

    func testPasswordWithoutSpecialCharacter() {
        let password = "Abcde1234"

        let result = authViewModel.isPasswordValid(password)

        XCTAssertFalse(result)
    }

    func testMatchingPasswords() {
        let password = "Abcde123!"
        let confirmPassword = "Abcde123!"

        let result = authViewModel.passwordsMatch(password,confirmPassword: confirmPassword)

        XCTAssertTrue(result)
    }

    func testPasswordsDoNotMatch() {
        let password = "Abcde123!"
        let confirmPassword = "Xyzab789!"

        let result = authViewModel.passwordsMatch(password,confirmPassword: confirmPassword)

        XCTAssertFalse(result)
    }

    func testMatchingPasswordsThatAreInvalid() {
        let password = "abc"
        let confirmPassword = "abc"

        let result = authViewModel.passwordsMatch(password,confirmPassword: confirmPassword)

        XCTAssertFalse(result)
    }
}
