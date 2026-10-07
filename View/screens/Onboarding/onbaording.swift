//
//  onbaording.swift
//  petpaw
//
//  Created by Piyumi Imalka on 2026-10-07.
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var currentStep = 0
    @State private var selectedPetImage: UIImage?
    @State private var showImagePicker = false

    var body: some View {
        ZStack {
            if currentStep == 0 {
                WelcomeScreen(currentStep: $currentStep)
            } else if currentStep == 1 {
                AddPetScreen(currentStep: $currentStep, selectedPetImage: $selectedPetImage, showImagePicker: $showImagePicker)
            } else if currentStep == 2 {
                quoteFeature(currentStep: $currentStep).environmentObject(authViewModel)
            } else if currentStep == 3 {
                dashboard()
                    .environmentObject(authViewModel)
                    .onAppear {
                        authViewModel.completeOnboarding()
                    }
            }
        }
        .sheet(isPresented: $showImagePicker) {
            selectImage(image: $selectedPetImage)
        }
    }
}

#Preview {
    OnboardingView()
}
