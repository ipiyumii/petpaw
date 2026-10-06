//
//  authService.swift
//  petpaw
//
//  Created by Piyumi Imalka on 2026-10-06.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class AuthService: NSObject, ObservableObject{
    @Published var isLoading = false
    @Published var errorMsg: String?
    @Published var currentUser: FirebaseAuth.User?
    
    override init() {
        super.init()
        self.currentUser = Auth.auth().currentUser
        
        Auth.auth().addStateDidChangeListener{
            [weak self] _, user in DispatchQueue.main.async {
                self?.currentUser = user
            }
        }
    }

    func signUp(email: String, password: String, fullName: String, completion: @escaping (Bool) -> Void) {
        isLoading = true
        errorMsg = nil

        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            DispatchQueue.main.async {
                self?.isLoading = false

                if let error = error {
                    self?.errorMsg = self?.parseAuthError(error)
                    completion(false)
                    return
                }

                guard let uid = authResult?.user.uid else {
                    self?.errorMsg = "Failed to create user"
                    completion(false)
                    return
                }

                self?.saveUserToFirestore(uid: uid, email: email, fullName: fullName) { success in
                    completion(success)
                }
            }
        }
    }

        func signIn(email: String, password: String, completion: @escaping (Bool) -> Void) {
        isLoading = true
        errorMsg = nil

        Auth.auth().signIn(withEmail: email, password: password) { [weak self] _, error in
            DispatchQueue.main.async {
                self?.isLoading = false

                if let error = error {
                    self?.errorMsg = self?.parseAuthError(error)
                    completion(false)
                } else {
                    completion(true)
                }
            }
        }
    }
    
    private func saveUserToFirestore(uid: String, email: String, fullName: String, completion: @escaping (Bool) -> Void) {
        let userData: [String: Any] = [
            "uid": uid,
            "email": email,
            "fullName": fullName,
            "createdAt": Timestamp(date: Date()),
            "updatedAt": Timestamp(date: Date())
        ]

        Firestore.firestore().collection(constants.Firebase.usersCollection).document(uid).setData(userData) { [weak self] error in
            if let error = error {
                self?.errorMsg = "Failed to save user data: \(error.localizedDescription)"
                completion(false)
            } else {
                completion(true)
            }
        }
    }

    private func parseAuthError(_ error: Error) -> String {
        if let authError = error as NSError? {
            switch authError.code {
            case AuthErrorCode.invalidEmail.rawValue:
                return "Invalid email address"
            case AuthErrorCode.weakPassword.rawValue:
                return "Password must be at least 6 characters"
            case AuthErrorCode.emailAlreadyInUse.rawValue:
                return "Email already in use"
            case AuthErrorCode.wrongPassword.rawValue:
                return "Incorrect password"
            case AuthErrorCode.userNotFound.rawValue:
                return "Account not found"
            case AuthErrorCode.tooManyRequests.rawValue:
                return "Too many login attempts. Try again later."
            default:
                return error.localizedDescription
            }
        }
        return error.localizedDescription
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            errorMsg = nil
        } catch let error {
            errorMsg = error.localizedDescription
        }
    }
}
    
    
