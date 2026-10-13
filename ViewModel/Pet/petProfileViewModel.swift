//
//  petProfileViewModel.swift
//  petpaw
//
//  Created by Piyumi Imalka on 2026-10-08.
//

import SwiftUI

@MainActor
final class PetProfileViewModel: ObservableObject {
    @Published var pet: Pet
    @Published var errorMessage: String?
    @Published var selectedPhoto: UIImage?
    @Published var showPhotoPicker = false
    @Published var isSaving = false
    let isNewPet: Bool
    private let service: PetServiceProtocol

    init(pet: Pet, isNewPet: Bool, service: PetServiceProtocol = PetService()) {
        self.pet = pet
        self.isNewPet = isNewPet
        self.service = service
    }

    var hasAnyInput: Bool {
        !pet.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        !pet.species.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        (pet.breed?.isEmpty == false) ||
        pet.dateOfBirth != nil ||
        pet.sex != .unknown ||
        pet.weightKg > 0
    }

    @discardableResult
    func save() async -> Bool {
        let trimmedName = pet.name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            errorMessage = "Please enter a name"
            return false
        }

        guard pet.weightKg > 0 else {
            errorMessage = "Please enter a valid weight"
            return false
        }

        pet.name = trimmedName
        isSaving = true
        errorMessage = nil

        do {
            if let selectedPhoto{
                let photoURL = try await service.uploadPhoto(selectedPhoto, petId: pet.id)
                pet.photoURL = photoURL
            }
            if isNewPet {
                try await service.createPet(pet)
            } else {
                try await service.updatePet(pet)
            }

            isSaving = false

            return true
            
            } catch {
                errorMessage = error.localizedDescription
                isSaving = false
                return false
            }
    }
}
