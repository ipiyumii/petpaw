//
//  userProfileViewModelTest.swift
//  petpawTests
//
//  Created by Piyumi Imalka on 2026-10-21.
//

import XCTest
@testable import petpaw

class MockUserProfileService: UserProfileServiceProtocol {
    var profileToReturn: UserProfile?
    var shouldThrowOnFetch = false
    var shouldThrowOnUpdate = false
    var didCallUpdateProfile = false
    var updatedProfile: UserProfile?

    func fetchProfile(uid: String) async throws -> UserProfile {
        if shouldThrowOnFetch 
        {
            throw NSError(domain: "TestError", code: 1)
        }

        guard let profileToReturn else 
        {
            throw NSError(domain: "TestError", code: 2)
        }

        return profileToReturn
    }

    func updateProfile(_ profile: UserProfile) async throws{
        if shouldThrowOnUpdate 
        {
            throw NSError(domain: "TestError", code: 3)
        }

        didCallUpdateProfile = true
        updatedProfile = profile
    }
}

@MainActor
class ProfileViewModelTests: XCTestCase {
    var mockService: MockUserProfileService!
    var viewModel: ProfileViewModel!

    override func setUp() {
        super.setUp()
        mockService = MockUserProfileService()
        viewModel = ProfileViewModel(service: mockService)
    }

    func makeTestProfile(
        fullName: String = "Piyumi",
        phoneNumber: String = "0771234567",
        bio: String = "Loves pets"
    ) -> UserProfile {
        return UserProfile(
            uid: "user1",
            fullName: fullName,
            email: "piyumi@petcare.app",
            phoneNumber: phoneNumber,
            bio: bio,
            createdAt: Date()
        )
    }

    func testHasUnsavedChangesAfterLoading() async {
        mockService.profileToReturn = makeTestProfile()

        await viewModel.loadProfile(uid: "user1")

        XCTAssertFalse(viewModel.hasUnsavedChanges)
    }

    func testHasUnsavedChangesAfterEditingName() async {
        mockService.profileToReturn = makeTestProfile()

        await viewModel.loadProfile(uid: "user1")
        viewModel.profile?.fullName = "New Name"

        XCTAssertTrue(viewModel.hasUnsavedChanges)
    }

    func testSaveWithBlankName() async {
        mockService.profileToReturn = makeTestProfile()
        await viewModel.loadProfile(uid: "user1")
        viewModel.profile?.fullName = "   "

        let result = await viewModel.save()

        XCTAssertFalse(result)
        XCTAssertFalse(mockService.didCallUpdateProfile)
        XCTAssertNotNil(viewModel.errorMessage)
    }

    func testSaveTrimsWhitespace() async {
        mockService.profileToReturn = makeTestProfile()
        await viewModel.loadProfile(uid: "user1")
        viewModel.profile?.fullName = "  Piyumi  "
        viewModel.profile?.bio = "  Loves pets  "

        let result = await viewModel.save()

        XCTAssertTrue(result)
        XCTAssertEqual(mockService.updatedProfile?.fullName, "Piyumi")
        XCTAssertEqual(mockService.updatedProfile?.bio, "Loves pets")
    }

    func testSaveWhenServiceThrowsError() async {
        mockService.profileToReturn = makeTestProfile()
        await viewModel.loadProfile(uid: "user1")
        mockService.shouldThrowOnUpdate = true

        let result = await viewModel.save()

        XCTAssertFalse(result)
        XCTAssertNotNil(viewModel.errorMessage)
    }
}
