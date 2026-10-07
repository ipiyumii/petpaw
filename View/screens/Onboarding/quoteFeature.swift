//
//  quoteFeature.swift
//  petpaw
//
//  Created by Piyumi Imalka on 2026-10-07.
//

import SwiftUI

struct quoteFeature: View {
    @Binding var currentStep: Int
    @State private var headingOpacity: Double = 0
    @State private var cardsOffset: CGFloat = 50
    @State private var cardsOpacity: Double = 0

    let features = [
        (icon: "💉", title: "Health Records", description: "Keep vaccinations, medications and vet visits organized."),
        (icon: "📸", title: "AI Health Scan", description: "Analyze pet health photos with on-device Core ML."),
        (icon: "🔔", title: "Never Miss a Reminder", description: "Stay on top of medications and important health dates.")
    ]

    var body: some View {
        ZStack {

            LinearGradient(
                gradient: Gradient(colors:[
                    PetPawColors.primary.opacity(0.1),
                    Color(red: 0.89, green: 0.945, blue: 0.914)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack {
                Spacer()
                HStack{
                    Spacer()
                    Circle()
                        .fill(PetPawColors.primary.opacity(0.08))
                        .frame(width: 200, height: 200)
                        .offset(x: 80, y: 80)
                }
            }
            .ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Button(action:{ currentStep = 1 }) {
                        HStack(spacing: 6){
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Back")
                        }
                        .foregroundColor(PetPawColors.primary)
                        .font(.system(size: 16, weight: .semibold))
                    }
                    Spacer()
                    Text("Features")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(PetPawColors.primary)
                        .tracking(0.3)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)

                ScrollView(showsIndicators: false){
                    VStack(spacing: 32) {
                        VStack(spacing: 12) {
                            Text("Stay ahead of your pet's health")
                                .font(.system(size: 28, weight: .bold, design: .default))
                                .tracking(-0.5)
                                .foregroundColor(Color(red: 0.06, green: 0.10, blue: 0.14))
                                .multilineTextAlignment(.center)

                            Text("Discover what makes PetPaw your pet's perfect health companion")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(Color(red: 0.40, green: 0.45, blue: 0.50))
                                .multilineTextAlignment(.center)
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 24)

                        .opacity(headingOpacity)
                        .onAppear {
                            withAnimation(.easeOut(duration: 0.6).delay(0.2)){
                                headingOpacity = 1.0
                            }
                        }


                        VStack(spacing: 16) {
                            ForEach(Array(features.enumerated()), id: \.offset) { index, feature in
                                FeatureCard(
                                    icon: feature.icon,
                                    title: feature.title,
                                    description: feature.description,
                                    delay: Double(index) * 0.15
                                )
                            }
                        }
                        .padding(.horizontal, 24)
                        .offset(y: cardsOffset)

                        .opacity(cardsOpacity)
                        .onAppear {
                            withAnimation(.easeOut(duration: 0.8).delay(0.3)){
                                cardsOffset = 0
                                cardsOpacity = 1.0
                            }
                        }

                        Spacer()
                            .frame(height: 20)
                    }
                }

                Button(action:{
                    currentStep = 3
                }) {
                    HStack(spacing: 8){
                        Text("Get Started").font(.system(size: 16, weight: .bold))
                        Image(systemName: "arrow.right").font(.system(size: 14, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .foregroundColor(.white)
                    .background(LinearGradient(
                                gradient: Gradient(colors:[
                                    PetPawColors.primary,
                                    Color(red: 0.14, green: 0.42, blue: 0.30)
                                ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(14)
                    .shadow(color: PetPawColors.primary.opacity(0.3), radius: 12, x: 0, y: 6)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }
}

struct FeatureCard: View {
    let icon: String
    let title: String
    let description: String
    let delay: Double

    @State private var isAnimated = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12){
                Text(icon)
                    .font(.system(size: 28))

                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(red: 0.06, green: 0.10, blue: 0.14))

                Spacer()
            }

            Text(description)
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(Color(red: 0.40, green: 0.45, blue: 0.50))
                .lineSpacing(1.5)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 14)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(
                    LinearGradient(gradient: Gradient(colors:[
                            PetPawColors.primary.opacity(0.2),
                            PetPawColors.primary.opacity(0.05)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),

                    lineWidth: 1.5
                )
        )
        .scaleEffect(isAnimated ? 1.0 : 0.95)
        .opacity(isAnimated ? 1.0 : 0.5)

        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(delay)){
                isAnimated = true
            }
        }
    }
}

#Preview {
    @State var step = 2
    return quoteFeature(currentStep: $step)
}
