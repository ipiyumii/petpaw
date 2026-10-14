//
//  petsViewModel.swift
//  petpaw
//
//  Created by Piyumi Imalka on 2026-10-12.
//

import Foundation

@MainActor
class PetsViewModel: ObservableObject {

    @Published var pets: [Pet] = []
    @Published var selectedPet: Pet?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let service: PetServiceProtocol

    init(service: PetServiceProtocol = PetService()) {
        self.service = service
    }

    func loadPets(ownerId: String) async {

        if ownerId.isEmpty {
            return
        }

        pets = service.fetchLocalPets(pwnerId: ownerId)
        if selectedPet == nil {
            selectedPet = pets.first
        }

        isLoading = pets.isEmpty
        errorMessage = nil

        do {
            let result = try await service.fetchPets(ownerId: ownerId)
            pets = result

            if selectedPet == nil || !result.contains(where:
            {
                $0.id == selectedPet?.id
            }) {
                selectedPet = result.first
            }
            service.saveLocally(_pets: result)

        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func select(_ pet: Pet) {
        selectedPet = pet
    }

    func addPet(_ pet: Pet) {
        pets.append(pet)
        selectedPet = pet
        service.saveLocally(_pets: [pet])
    }

    func replacePet(_ pet: Pet) {

        for i in 0..<pets.count {
            if pets[i].id == pet.id {
                pets[i] = pet
                selectedPet = pet
                return
            }
        }
        pets.append(pet)
        selectedPet = pet
        service.saveLocally(_pets: [pet])
    }
}
