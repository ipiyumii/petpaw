//
//  petService.swift
//  petpaw
//
//  Created by Piyumi Imalka on 2026-10-12.
//

import Foundation
import FirebaseFirestore

protocol PetServiceProtocol {
    func fetchPets(ownerId: String) async throws -> [Pet]
    func createPet(_ pet: Pet) async throws
    func updatePet(_ pet: Pet) async throws
}

class PetService: PetServiceProtocol {

    private let firestore = Firestore.firestore()

    func fetchPets(ownerId: String) async throws -> [Pet] {

        let result = try await firestore
            .collection(constants.Firebase.petsCollection)
            .whereField("ownerId", isEqualTo: ownerId)
            .getDocuments()

        var pets: [Pet] = []

        for document in result.documents {
            let data = document.data()

            if let pet = decodePet(id: document.documentID, data: data) {
                pets.append(pet)
            }
        }

        return pets
    }

    func createPet(_ pet: Pet) async throws {

        let data = encodePet(pet)

        try await firestore
            .collection(constants.Firebase.petsCollection)
            .document(pet.id)
            .setData(data)
    }

    func updatePet(_ pet: Pet) async throws {

        let data = encodePet(pet)

        try await firestore
            .collection(constants.Firebase.petsCollection)
            .document(pet.id)
            .setData(data, merge: true)
    }

    private func encodePet(_ pet: Pet) -> [String: Any] {

        var data: [String: Any] = [
            "ownerId": pet.ownerId,
            "name": pet.name,
            "species": pet.species,
            "sex": pet.sex.rawValue,
            "weightKg": pet.weightKg
        ]

        if let breed = pet.breed {
            data["breed"] = breed
        }

        if let photoURL = pet.photoURL {
            data["photoURL"] = photoURL
        }

        if let dateOfBirth = pet.dateOfBirth {
            data["dateOfBirth"] = Timestamp(date: dateOfBirth)
        }

        return data
    }

    private func decodePet(id: String, data: [String: Any]) -> Pet? {

        guard let ownerId = data["ownerId"] as? String else {
            return nil
        }

        guard let name = data["name"] as? String else {
            return nil
        }

        guard let species = data["species"] as? String else {
            return nil
        }

        let sexValue = data["sex"] as? String ?? ""
        let sex = PetSex(rawValue: sexValue) ?? .unknown

        let weightKg = data["weightKg"] as? Double ?? 0
        let dateOfBirth = (data["dateOfBirth"] as? Timestamp)?.dateValue()
        let breed = data["breed"] as? String
        let photoURL = data["photoURL"] as? String

        let pet = Pet(
            id: id,
            ownerId: ownerId,
            name: name,
            species: species,
            breed: breed,
            dateOfBirth: dateOfBirth,
            sex: sex,
            weightKg: weightKg,
            photoURL: photoURL
        )

        return pet
    }
}

