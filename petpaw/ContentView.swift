//
//  ContentView.swift
//  petpaw
//
//  Created by Piyumi Imalka on 2026-10-04.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            PetPawColors.background.ignoresSafeArea()
            
            VStack(spacing: Spacing.lg) {
                VStack(spacing: Spacing.sm){
                    Text("Welcome to PetPaw!")
                        .font(PetPawTypography.h1)
                        .foregroundColor(PetPawColors.text)

                    Text("Health care for your beloved pets")
                        .font(PetPawTypography.body)
                        .foregroundColor(PetPawColors.textSecondary)
                    
                }
                .padding(.top, Spacing.xxl)
                
                VStack {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 60))
                        .foregroundColor(PetPawColors.primary)
                }
                frame(height: 150)
                
                VStack(spacing: Spacing.md) {
                    FeatureRow(icon: "heart.circle.fill", title: "Track Health", subtitle: "Monitor vaccinations & medications")
                    FeatureRow(icon: "map.circle.fill", title: "Find Vets", subtitle: "Locate nearby veterinarians")
                    FeatureRow(icon: "camera.circle.fill", title: "Health Scans", subtitle: "AI-powered pet analysis")

                }
                .padding(Spacing.lg)
                .background(PetPawColors.card)
                .cornerRadius(Spacing.Card.cornerRadius)
                
                Spacer()
                
                Button(action: {}) {
                    Text("Get Started")
                        .font(PetPawTypography.button)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(PetPawColors.primary)
                        .cornerRadius(8)
                }
                .padding(.horizontal, Spacing.xxl)
                .padding(.bottom, Spacing.xxl)

            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(PetPawColors.primary)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(title)
                    .font(PetPawTypography.h3)
                    .foregroundColor(PetPawColors.text)

                Text(subtitle)
                    .font(PetPawTypography.caption)
                    .foregroundColor(PetPawColors.textSecondary)
            }
            Spacer()

        }
    }
}

#Preview {
    ContentView()
}
