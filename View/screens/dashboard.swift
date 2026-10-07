//
//  dashboard.swift
//  petpaw
//
//  Created by Piyumi Imalka on 2026-10-07.
//

import SwiftUI

struct dashboard: View {
    @EnvironmentObject var authViewModel: AuthViewModel

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
    }
}

#Preview {
    dashboard()
        .environmentObject(AuthViewModel())
}
