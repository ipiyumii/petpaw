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
        } else {
             MainTabView()
                .environmentObject(authViewModel)
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
