//
//  userProfileService.swift
//  petpaw
//
//  Created by Piyumi Imalka on 2026-10-08.
//

import Foundation
import FirebaseFirestore

protocol UserProfileServiceProtocol {
    func fetchProfile(uid: String) async throws -> UserProfile
    func updateProfile(_ profile: UserProfile) async throws
}

final class UserProfileService: UserProfileServiceProtocol {
    private let firestore = Firestore.firestore()

    func fetchProfile(uid: String) async throws -> UserProfile {
        let snapshot = try await firestore
            .collection(constants.Firebase.usersCollection)
            .document(uid)
            .getDocument()

        guard let data = snapshot.data() else {
            throw NSError(
                domain: "UserProfile",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Profile not found."]
            )
        }

        guard let fullName = data["fullName"] as? String,
              let email = data["email"] as? String else {
            throw NSError(
                domain: "UserProfile",
                code: 2,
                userInfo: [NSLocalizedDescriptionKey: "Invalid profile data."]
            )
        }

        return UserProfile(
            uid: uid,
            fullName: fullName,
            email: email,
            phoneNumber: data["phoneNumber"] as? String ?? "",
            bio: data["bio"] as? String ?? "",
            createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
        )
    }

    func updateProfile(_ profile: UserProfile) async throws {
        let data: [String: Any] = [
            "uid": profile.uid,
            "fullName": profile.fullName,
            "email": profile.email,
            "phoneNumber": profile.phoneNumber,
            "bio": profile.bio
        ]

        try await firestore
            .collection(constants.Firebase.usersCollection)
            .document(profile.uid)
            .setData(data, merge: true)
    }
}
