//
//  PetsViewModelTests.swift
//  petpawTests
//
//  Created by Piyumi Imalka on 2026-10-15.
//

import XCTest
import UIKit
@testable import petpaw

class MockPetService: PetServiceProtocol {
    var petsToReturnFromFirestore: [Pet] = []
    var petsToReturnFromCache: [Pet] = []
    var shouldThrowError = false

    var didCallSaveLocally = false
    var savedLocallyPets: [Pet] = []

    func fetchPets(ownerId: String) async throws -> [Pet] 
    {
        if shouldThrowError {
            throw NSError(domain: "TestError", code: 1)
        }
        return petsToReturnFromFirestore
    }

    func createPet(_ pet: Pet) async throws {}

    func updatePet(_ pet: Pet) async throws {}

    func uploadPhoto(_ image: UIImage, petId: String) async throws -> String 
    {
        return ""
    }

    func saveLocally(_pets pets: [Pet]) 
    {
        didCallSaveLocally = true
        savedLocallyPets = pets
    }

    func fetchLocalPets(pwnerId ownerId: String) -> [Pet] 
    {
        return petsToReturnFromCache
    }
}

@MainActor
class PetsViewModelTests: XCTestCase {
    var mockService: MockPetService!
    var viewModel: PetsViewModel!

    override func setUp() {
        super.setUp()
        mockService = MockPetService()
        viewModel = PetsViewModel(service: mockService)
    }

    func makeTestPet(id: String = "1", name: String = "Buddy") -> Pet {
        return Pet(
            id: id,
            ownerId: "owner1",
            name: name,
            species: "Dog",
            breed: nil,
            dateOfBirth: nil,
            sex: .unknown,
            weightKg: 10,
            photoURL: nil
        )
    }

    //loadPets
    func testLoadPets_WhenCacheHasPets_ShowsThemImmediately() async {
        //Given -local cache already has one pet saved
        let cachedPet = makeTestPet(id: "cached-1", name: "Cached Cat")
        mockService.petsToReturnFromCache = [cachedPet]
        mockService.petsToReturnFromFirestore = [cachedPet]

        //When
        await viewModel.loadPets(ownerId: "owner1")

        //Then
        XCTAssertEqual(viewModel.pets.count, 1)
        XCTAssertEqual(viewModel.pets.first?.name, "Cached Cat")
    }

    func testLoadPets_WhenFirestoreSucceeds_UpdatesPetsAndSavesToCache() async {
        //Given
        let freshPet = makeTestPet(id: "fresh-1", name: "Fresh Dog")
        mockService.petsToReturnFromCache = []
        mockService.petsToReturnFromFirestore = [freshPet]

        //When
        await viewModel.loadPets(ownerId: "owner1")

        //Then
        XCTAssertEqual(viewModel.pets.first?.name, "Fresh Dog")
        XCTAssertTrue(mockService.didCallSaveLocally)
        XCTAssertEqual(mockService.savedLocallyPets.first?.name, "Fresh Dog")
    }

    func testLoadPets_WhenFirestoreFails_KeepsShowingCachedPets() async {
        //Given- cache has a pet but firestore throws an error
        let cachedPet = makeTestPet(id: "cached-1", name: "Offline Cat")
        mockService.petsToReturnFromCache = [cachedPet]
        mockService.shouldThrowError = true

        //When
        await viewModel.loadPets(ownerId: "owner1")

        //Then
        XCTAssertEqual(viewModel.pets.first?.name, "Offline Cat")
        XCTAssertNil(viewModel.errorMessage)
    }

    func testLoadPets_WhenFirestoreFailsAndCacheIsEmpty_ShowsErrorMessage() async 
    {
        //Given - no cache firestore fails too
        mockService.petsToReturnFromCache = []
        mockService.shouldThrowError = true

        //When
        await viewModel.loadPets(ownerId: "owner1")

        //Then
        XCTAssertTrue(viewModel.pets.isEmpty)
        XCTAssertNotNil(viewModel.errorMessage)
    }

    func testLoadPets_WhenOwnerIdIsEmpty_DoesNothing() async {
        //When
        await viewModel.loadPets(ownerId: "")

        //Then
        XCTAssertTrue(viewModel.pets.isEmpty)
    }

    //addPet
    func testAddPet_AddsPetAndSelectsIt() {
        //Given
        let newPet = makeTestPet(id: "new-1", name: "New Puppy")

        //When
        viewModel.addPet(newPet)

        //Then
        XCTAssertEqual(viewModel.pets.count, 1)
        XCTAssertEqual(viewModel.selectedPet?.name, "New Puppy")
        XCTAssertTrue(mockService.didCallSaveLocally)
    }

    //replacePet
    func testReplacePet_WhenPetExists_UpdatesIt() 
    {
        //Given- a pet already in the list
        let originalPet = makeTestPet(id: "1", name: "Old Name")
        viewModel.addPet(originalPet)

        //When- we save it again with a new name
        var updatedPet = originalPet
        updatedPet.name = "New Name"
        viewModel.replacePet(updatedPet)

        //Then
        XCTAssertEqual(viewModel.pets.count, 1)
        XCTAssertEqual(viewModel.pets.first?.name, "New Name")
    }

    func testReplacePet_WhenPetDoesNotExist_DoesNothing() {
        //Given- an empty pets list
        let unknownPet = makeTestPet(id: "unknown-id", name: "Ghost")

        //When
        viewModel.replacePet(unknownPet)

        XCTAssertTrue(viewModel.pets.isEmpty)
    }

    //select
    func testSelect_SetsSelectedPet() {
        let pet = makeTestPet()
        viewModel.select(pet)
        XCTAssertEqual(viewModel.selectedPet?.id, pet.id)
    }
}
