//
//  welcomeScreen.swift
//  petpaw
//
//  Created by Piyumi Imalka on 2026-10-06.
//

import SwiftUI

struct WelcomeScreen: View {
    @Binding var currentStep: Int
    @State private var titleScale: CGFloat = 0.8
    @State private var titleOpacity: Double = 0
    @State private var pawScale: CGFloat = 1.0

    var body: some View {
        ZStack{
            LinearGradient(
                gradient: Gradient(colors:[
                    PetPawColors.primary.opacity(0.15),
                    Color(red: 0.89, green: 0.945, blue: 0.914)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack {
                HStack {
                    ZStack{
                        Circle()
                            .fill(PetPawColors.primary.opacity(0.1))
                            .frame(width: 250, height: 250)
                            .offset(x: -100, y: -100)
                    }

                    Spacer()
                }
                Spacer()
            }
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                .frame(height: 60)

                VStack(spacing: 24) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(
                                    gradient: Gradient(colors: [
                                        PetPawColors.primary.opacity(0.2),
                                        PetPawColors.primary.opacity(0.05)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 140, height: 140)
                            .shadow(color: PetPawColors.primary.opacity(0.2), radius: 20, x: 0, y: 10)

                        Circle().fill(Color.white).frame(width: 120, height: 120)

                        Image(systemName: "pawprint.fill").font(.system(size: 60, weight: .semibold)).foregroundColor(PetPawColors.primary)
                    }
                    .scaleEffect(pawScale)

                    .onAppear {
                        withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                            pawScale = 1.05
                        }
                    }

                    VStack(spacing: 8) {
                        HStack(spacing: 0) {
                            Text("Pet")
                                .font(.system(size: 36, weight: .bold, design: .default))
                                .foregroundColor(PetPawColors.primary)
                            +
                            Text("Paw")
                                .font(.system(size: 36, weight: .bold, design: .default))
                                .foregroundColor(Color(red: 0.12, green: 0.35, blue: 0.25))
                        }

                        Text("Your Pet's Health Companion")
                            .font(.system(size: 14, weight: .medium))
                            .tracking(0.5)
                            .foregroundColor(Color(red: 0.45, green: 0.50, blue: 0.55))
                    }
                }
                .padding(.horizontal, 24)

                Spacer()
               .frame(height: 60)

                VStack(spacing: 12) {
                    Text("Everything your pet needs, in one place")
                        .font(.system(size: 32, weight: .bold, design: .default))
                        .tracking(-0.5)
                        .foregroundColor(Color(red: 0.06, green: 0.10, blue: 0.14))
                        .multilineTextAlignment(.center)
                        .scaleEffect(titleScale)
                        .opacity(titleOpacity)

                    Text("Keep your pet's health records, medications, vaccinations, and important information organized.")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(Color(red: 0.40, green: 0.45, blue: 0.50))
                        .multilineTextAlignment(.center)
                        .lineSpacing(2)
                }
                .padding(.horizontal, 24)

                .onAppear {
                    withAnimation(.easeOut(duration: 0.8).delay(0.2)){
                        titleScale = 1.0
                        titleOpacity = 1.0
                    }
                }

                Spacer()

                Button(action: { currentStep = 1 }) {

                    HStack(spacing: 8){
                        Text("Next")
                            .font(.system(size: 16, weight: .bold))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .foregroundColor(.white)
                    .background(LinearGradient(
                            gradient: Gradient(colors: [
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

#Preview {
    @State var step = 0
    return WelcomeScreen(currentStep: $step)
}
