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

    init(pet: Pet) {
        self.pet = pet
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
    func save() -> Bool {
        guard !pet.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Please enter a name"
            return false
        }

        guard pet.weightKg > 0 else {
            errorMessage = "Please enter a valid weight"
            return false
        }

        errorMessage = nil
        return true
    }
}
