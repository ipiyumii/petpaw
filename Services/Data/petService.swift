//
//  petService.swift
//  petpaw
//
//  Created by Piyumi Imalka on 2026-10-12.
//

import FirebaseFirestore
import UIKit

protocol PetServiceProtocol {
    func fetchPets(ownerId: String) async throws -> [Pet]
    func createPet(_ pet: Pet) async throws
    func updatePet(_ pet: Pet) async throws
    func uploadPhoto(_ image: UIImage, petId: String) async throws -> String
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

    func uploadPhoto(_ image: UIImage, petId: String) async throws -> String {
        guard let data = image.resized(maxDimension: 400)
            .jpegData(compressionQuality: 0.5) else {
            throw NSError(
                domain: "PetService",
                code: 0,
                userInfo: [
                    NSLocalizedDescriptionKey: "Could not process photo"
                ]
            )
        }

        return "data:image/jpeg;base64,\(data.base64EncodedString())"
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

private extension UIImage {
    func resized(maxDimension: CGFloat) -> UIImage {
        let scale = min(1, maxDimension / max(size.width, size.height))

        guard scale < 1 else {
            return self
        }

        let newSize = CGSize(
            width: size.width * scale,
            height: size.height * scale
        )

        return UIGraphicsImageRenderer(size: newSize).image { _ in
            draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}

