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

        isLoading = true
        errorMessage = nil

        do {
            let result = try await service.fetchPets(ownerId: ownerId)
            pets = result

            if pets.count > 0 && selectedPet == nil {
                selectedPet = pets[0]
            }

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
    }

    func replacePet(_ pet: Pet) {

        for i in 0..<pets.count {
            if pets[i].id == pet.id {
                pets[i] = pet
                selectedPet = pet
                return
            }
        }
    }
}
