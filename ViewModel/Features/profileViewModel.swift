//
//  profileViewModel.swift
//  petpaw
//
//  Created by Piyumi Imalka on 2026-10-08.
//

import Foundation

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var profile: UserProfile?
    @Published var isLoading = false
    @Published var isSaving = false
    @Published var errorMessage: String?

    private var originalProfile: UserProfile?

    var hasUnsavedChanges: Bool {
        guard let profile = profile else { return false }
        guard let originalProfile = originalProfile else { return false }

        return profile.fullName != originalProfile.fullName ||
               profile.phoneNumber != originalProfile.phoneNumber ||
               profile.bio != originalProfile.bio
    }

    func loadProfile(uid: String) async {
        // todo
    }

    func save() async -> Bool {
        guard let profile = profile else {
            return false
        }

        if profile.fullName.isEmpty {
            errorMessage = "Please enter your name"
            return false
        }

        isSaving = true
        errorMessage = nil

        do {
            originalProfile = profile
            isSaving = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            isSaving = false
            return false
        }
    }
}
