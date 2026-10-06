//
//  authViewModel.swift
//  petpaw
//
//  Created by Piyumi Imalka on 2026-10-06.
//

import Foundation
import FirebaseAuth

class AuthViewModel: ObservableObject{
    @Published var authService = AuthService()
    @Published var isAuthenticated = false
    @Published var showError = false
    @Published var errorMsg = ""

    @Published var signUpName = ""
    @Published var signUpEmail = ""
    @Published var signUpPassword = ""
    @Published var signUpConfirmPassword = ""
    @Published var isSignUpLoading = false
    @Published var acceptedTerms = false
    
    init() {
        isAuthenticated = Auth.auth().currentUser != nil
    }

    func signUp() {
        guard validateSignUpInput() else { return }

        isSignUpLoading = true
        authService.signUp(email: signUpEmail, password: signUpPassword, fullName: signUpName) { [weak self] success in
            self?.isSignUpLoading = false
            if success {
                self?.isAuthenticated = true
            } else {
                self?.handleError(self?.authService.errorMsg ?? "Sign up failed")
            }
        }
    }

    private func validateSignUpInput() -> Bool {
        guard !signUpEmail.isEmpty else {
            handleError("Please enter your email")
            return false
        }

        guard isValidEmail(signUpEmail) else {
            handleError("Please enter a valid email")
            return false
        }

        guard !signUpPassword.isEmpty else {
            handleError("Please enter a password")
            return false
        }

        guard signUpPassword.count >= 6 else {
            handleError("Password must be at least 6 characters")
            return false
        }

        guard signUpPassword == signUpConfirmPassword else {
            handleError("Passwords do not match")
            return false
        }

        guard acceptedTerms else {
            handleError("Please accept the terms and conditions")
            return false
        }

        return true
    }

    func isPasswordValid(_ password: String) -> Bool {
        return password.count >= 6
    }

    func passwordsMatch(_ password: String, confirmPassword: String) -> Bool {
        return password == confirmPassword && password.count >= 6
    }

    
    private func handleError(_ message: String) {
        errorMsg = message
        showError = true
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }


}
