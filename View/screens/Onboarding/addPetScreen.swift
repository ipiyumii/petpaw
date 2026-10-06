//
//  addPetScreen.swift
//  petpaw
//
//  Created by Piyumi Imalka on 2026-10-06.
//

import SwiftUI

struct AddPetScreen: View {
    @Binding var currentStep: Int
    @Binding var selectedPetImage: UIImage?
    @Binding var showImagePicker: Bool
    @State private var imageScale: CGFloat = 0.8
    @State private var titleOpacity: Double = 0

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.89, green: 0.945, blue: 0.914),
                    PetPawColors.primary.opacity(0.1)
                ]),
                startPoint: .topLeading,

                endPoint: .bottomTrailing
            )

            .ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Button(action: { currentStep = 0 }) {

                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Back")
                        }
                        .foregroundColor(PetPawColors.primary)
                        .font(.system(size: 16, weight: .semibold))
                    }
                    Spacer()
                    Text("Add Pet")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(PetPawColors.primary)
                        .tracking(0.3)
                }
                .padding(.horizontal, 24)

                .padding(.vertical, 16)

                ScrollView(showsIndicators: false){
                    VStack(spacing: 32) {

                        VStack(spacing: 12) {
                            Text("Let's see your cute pet 🐾")
                                .font(.system(size: 28, weight: .bold, design: .default))
                                .tracking(-0.5)
                                .foregroundColor(Color(red: 0.06, green: 0.10, blue: 0.14))
                                .multilineTextAlignment(.center)
                                .opacity(titleOpacity)

                            Text("Upload a photo to personalize your pet's profile")
                                .font(.system(size: 14, weight: .regular))

                                .foregroundColor(Color(red: 0.40, green: 0.45, blue: 0.50))
                                .multilineTextAlignment(.center)
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 24)
                        .onAppear{
                            withAnimation(.easeOut(duration: 0.6).delay(0.2)) {
                                titleOpacity = 1.0
                            }
                        }


                        VStack(spacing: 16){
                            if let petImage = selectedPetImage{
                                Image(uiImage: petImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 300)
                                    .cornerRadius(16)
                                    .clipped()
                                    .shadow(color: PetPawColors.primary.opacity(0.2), radius: 12, x: 0, y: 6)
                                    .scaleEffect(imageScale)
                                    .onAppear {
                                        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                                            imageScale = 1.0
                                        }
                                    }
                            } else {
                                Button(action: { showImagePicker = true }){
                                    VStack(spacing: 16) {
                                        ZStack {
                                            Circle()
                                                .fill(
                                                    LinearGradient(
                                                        gradient: Gradient(colors:[
                                                            PetPawColors.primary.opacity(0.15),
                                                            PetPawColors.primary.opacity(0.05)
                                                        ]),
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    )
                                                )
                                                .frame(width: 120, height: 120)

                                            Image(systemName: "camera.fill")
                                                .font(.system(size: 44, weight: .semibold))
                                                .foregroundColor(PetPawColors.primary)
                                        }

                                        VStack(spacing: 4) {
                                            Text("Upload Pet Photo")
                                                .font(.system(size: 16, weight: .bold))
                                                .foregroundColor(Color(red: 0.06, green: 0.10, blue: 0.14))

                                            Text("Tap to add your pet's photo")
                                                .font(.system(size: 13, weight: .regular))
                                                .foregroundColor(Color(red: 0.40, green: 0.45, blue: 0.50))
                                        }
                                    }
                                    .frame(height: 300)
                                    .frame(maxWidth: .infinity)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(Color.white)
                                            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(
                                                PetPawColors.primary.opacity(0.2),
                                                lineWidth: 2
                                            )
                                    )
                                }
                                .scaleEffect(imageScale)
                                .onAppear {
                                    withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                                        imageScale = 1.0
                                    }
                                }
                            }

                            if selectedPetImage != nil {
                                Button(action: { showImagePicker = true }){
                                    HStack {
                                        Image(systemName: "arrow.clockwise")
                                        Text("Change Photo")
                                    }
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(PetPawColors.primary)
                                }
                                .padding(.top, 8)
                            }
                        }
                        .padding(.horizontal, 24)

                        Spacer()
                            .frame(height: 20)
                    }
                }

                VStack(spacing: 12) {
                    Button(action: { currentStep = 2 }) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Add Pet")
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .foregroundColor(.white)
                        .background(
                            LinearGradient(
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

                    Button(action: { currentStep = 2 }){
                        Text("Skip for now")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(PetPawColors.primary)
                    }
                }

                .padding(.horizontal, 24)

                .padding(.bottom, 40)
            }
        }
    }
}

#Preview {
    @State var step = 1
    @State var petImage: UIImage? = nil
    @State var showPicker = false
    return AddPetScreen(currentStep: $step, selectedPetImage: $petImage, showImagePicker: $showPicker)
}
