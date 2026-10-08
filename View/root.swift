//
//  root.swift
//  petpaw
//
//  Created by Piyumi Imalka on 2026-10-05.
//

import SwiftUI

struct RootView: View {
    @StateObject private var authViewModel = AuthViewModel()

    var body: some View {
        if !authViewModel.isAuthenticated {
            AuthenticationFlow()
                .environmentObject(authViewModel)
        } else if !authViewModel.hasCompletedOnboarding {
            OnboardingView()
                .environmentObject(authViewModel)
        } else if !authViewModel.isUlocked {
            LockScreen(onUnlock: {authViewModel.isUlocked = true})
        }else {
             MainTabView()
                .environmentObject(authViewModel)
        }
    }
}

private struct LockScreen: View {
    let onUnlock: () -> Void
    @State private var errorMessage: String?
    private let biometricService = BioMetricService()

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "faceid")
                .font(.system(size: 60))
                .foregroundColor(PetPawColors.primary)

            Text("Unlock PetPaw")
                .font(PetPawTypography.h3)
                .foregroundColor(PetPawColors.textPrimary)

            if let errorMessage {
                Text(errorMessage)
                    .font(PetPawTypography.bodySmall)
                    .foregroundColor(PetPawColors.danger)
                    .multilineTextAlignment(.center)
            }

            Button("Try Again", action: authenticate)
                .font(PetPawTypography.button)
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(PetPawColors.primary)
                .cornerRadius(12)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .task { authenticate() }
    }

    private func authenticate() {
        errorMessage = nil
        biometricService.authenticate { success, message in
            if success {
                onUnlock()
            } else {
                errorMessage = message ?? "Authentication failed"
            }
        }
    }
}

struct AuthenticationFlow: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var isSignUp = false

    var body: some View {
        NavigationStack {
            if isSignUp {
                signup(isSignUp: $isSignUp)
            } else {
                Login(isSignUp: $isSignUp)
                    .onAppear {
                        isSignUp = false
                    }
            }
        }
    }
}

#Preview {
    RootView()
}
