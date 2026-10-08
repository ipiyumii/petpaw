//
//  pet.swift
//  petpaw
//
//  Created by Piyumi Imalka on 2026-10-08.
//

import Foundation

enum PetSex: String, Codable, CaseIterable {
    case male = "Male"
    case female = "Female"
    case unknown = "Unknown"
}

struct Pet: Codable, Equatable, Identifiable {
    var id: String
    var ownerId: String
    var name: String
    var species: String
    var breed: String?
    var dateOfBirth: Date?
    var sex: PetSex
    var weightKg: Double
    var photoURL: String?

    var ageInYears: Int? {
        guard let dateOfBirth else { return nil }
        return Calendar.current.dateComponents([.year], from: dateOfBirth, to: Date()).year
    }
}
