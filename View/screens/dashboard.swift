//
//  dashboard.swift
//  petpaw
//
//  Created by Piyumi Imalka on 2026-10-07.
//

import SwiftUI

struct dashboard: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showProfile = false

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.98, green: 1.0, blue: 0.99),
                    Color(red: 1.0, green: 1.0, blue: 1.0)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {

                HStack {
                    Spacer()

                    Button(action: { showProfile = true }) {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(PetPawColors.primary)
                            .frame(width: 40, height: 40)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(color: PetPawColors.shadowLight, radius: 4, x: 0, y: 2)
                    }
                    .accessibilityLabel("Your profile")
                    .accessibilityHint("Double-tap to view and edit your profile")
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.top, Spacing.sm)
                
                VStack(spacing: 12) {
                    Text("Welcome! 🐾")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(Color(red: 0.08, green: 0.12, blue: 0.16))

                    Text("You're all set!")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(red: 0.45, green: 0.50, blue: 0.55))
                }
                .padding(.top, 40)

                Spacer()

                Button(action: {
                    authViewModel.signOut()
                }) {
                    HStack {
                        Image(systemName: "arrow.right.square")
                        Text("Sign Out")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .foregroundColor(.white)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                PetPawColors.primary,
                                Color(red: 0.14, green: 0.42, blue: 0.30)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(12)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .sheet(isPresented: $showProfile) {
            UserProfileScreen()
        }
    }
}

#Preview {
    dashboard()
        .environmentObject(AuthViewModel())
}
