//
//   healthScanTab.swift
//  petpaw
//
//  Created by Piyumi Imalka on 2026-10-14.
//

import Foundation
import SwiftUI

enum ScanStep: Int, CaseIterable {
    case photo = 1
    case area
    case analysis
    case result

    var title: String {
        switch self {
            case .photo:
                return "Photo"
            case .area:
                return "Area"
            case .analysis:
                return "Analysis"
            case .result:
                return "Result"
        }
    }
}

enum ScanBodyArea: String, CaseIterable, Identifiable {
    case skin = "Skin"
    case eyes = "Eyes"
    case ears = "Ears"
    case teeth = "Teeth"
    case paw = "Paw"
    case other = "Other"

    var id: String {
        rawValue
    }

    var icon: String {
        switch self {
        case .skin:
            return "viewfinder"
        case .eyes:
            return "eye.fill"
        case .ears:
            return "ear.fill"
        case .teeth:
            return "face.smiling.fill"
        case .paw:
            return "pawprint.fill"
        case .other:
            return "plus.circle.fill"
        }
    }
}

struct HealthScanTab: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    @State private var capturedImage: UIImage?
    @State private var selectedArea: ScanBodyArea = .skin
    @State private var showCamera = false
    @State private var showLibraryPicker = false
    @State private var isAnalyzing = false
    @State private var showResult = false

    var currentStep: ScanStep {
        if showResult {
            return .result
        } else if isAnalyzing {
            return .analysis
        } else if capturedImage == nil {
            return .photo
        } else {
            return .area
        }
    }

    var body: some View {
        VStack(spacing: Spacing.lg) 
        {
            stepIndicator

            if showResult 
            {
                resultCard
            } 
            else {
                photoFrame
                captureButtons
                areaPicker
                disclaimer
                analyseButton
            }
        }
        .frame(maxWidth: 700)
        .sheet(isPresented: $showCamera) {
            CameraCapture(image: $capturedImage)
        }
        .sheet(isPresented: $showLibraryPicker) {
            selectImage(image: $capturedImage)
        }
    }

    var stepIndicator: some View {
        HStack {
            ForEach(ScanStep.allCases, id: \.self){ 
                step in
                VStack(spacing: Spacing.xs)
                {
                    Circle()
                        .fill(step == currentStep ? PetPawColors.primary : PetPawColors.primaryBg)
                        .frame(width: 28, height: 28)

                        .overlay {
                            Text("\(step.rawValue)")
                                .font(PetPawTypography.caption.weight(.bold))
                                .foregroundColor(step == currentStep ? .white : PetPawColors.textTertiary)
                        }

                    Text(step.title)
                        .font(PetPawTypography.caption)
                        .foregroundColor(step == currentStep ? PetPawColors.primary : PetPawColors.textTertiary)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }

    var photoFrame: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(PetPawColors.primaryBg.opacity(0.5))

            if let capturedImage = capturedImage
            {
                Image(uiImage: capturedImage)
                    .resizable()
                    .scaledToFill()
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            } else {
                VStack(spacing: Spacing.sm) {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 32))
                        .foregroundColor(PetPawColors.primary)

                    Text("Position the area in frame")
                        .font(PetPawTypography.bodySmall)
                        .foregroundColor(PetPawColors.textSecondary)
                }
            }
        }
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    PetPawColors.primary,
                    style: StrokeStyle(lineWidth: 2, dash: [8])
                )
        }
        .aspectRatio(4 / 3, contentMode: .fit)
        .clipped()
    }

    var captureButtons: some View {
        HStack(spacing: Spacing.lg) 
        {
            Button {
                showLibraryPicker = true
            } label: {
                Image(systemName: "photo.on.rectangle")
                    .font(.system(size: 18))
                    .foregroundColor(PetPawColors.textSecondary)
                    .frame(width: 48, height: 48)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: PetPawColors.shadowLight, radius: 6, x: 0, y: 2)
            }
            .accessibilityLabel("Choose photo from library")

            Button {
                showCamera = true
            } label: {
                Image(systemName: "camera.fill")
                    .font(.system(size: 22))
                    .foregroundColor(.white)
                    .frame(width: 64, height: 64)
                    .background(PetPawColors.primary)
                    .clipShape(Circle())
                    .shadow(color: PetPawColors.primary.opacity(0.3), radius: 10, x: 0, y: 5)
            }
            .accessibilityLabel("Take photo")

            Button {
                showCamera = true
            } label: {
                Image(systemName: "viewfinder")
                    .font(.system(size: 18))
                    .foregroundColor(PetPawColors.textSecondary)
                    .frame(width: 48, height: 48)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: PetPawColors.shadowLight, radius: 6, x: 0, y: 2)
            }
            .accessibilityLabel("Take photo")
        }
    }

    var areaPicker: some View {
        VStack(alignment: .leading, spacing: Spacing.sm){
            Text("Select area to analyse")
                .font(PetPawTypography.body.weight(.semibold))
                .foregroundColor(PetPawColors.textPrimary)

            LazyVGrid(columns: gridColumns, spacing: Spacing.sm) {
                ForEach(ScanBodyArea.allCases) { area in
                    Button {
                        selectedArea = area
                    } label: {
                        VStack(spacing: Spacing.xs) {
                            Image(systemName: area.icon)
                                .font(.system(size: 18))

                            Text(area.rawValue)
                                .font(PetPawTypography.bodySmall.weight(.semibold))
                        }
                        .foregroundColor(selectedArea == area ? PetPawColors.primary : PetPawColors.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Spacing.sm)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(selectedArea == area ? PetPawColors.primaryBg : Color.white)
                        )
                        .overlay {
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(
                                    selectedArea == area ? PetPawColors.primary : Color.clear,
                                    lineWidth: 1.5
                                )
                        }
                        .shadow(color: PetPawColors.shadowLight, radius: 4, x: 0, y: 2)
                    }
                }
            }
        }
    }

    var gridColumns: [GridItem] {
        if horizontalSizeClass == .regular 
        {
            return Array(repeating: GridItem(.flexible()), count: 4)
        } else {
            return Array(repeating: GridItem(.flexible()), count: 3)
        }
    }

    var disclaimer: some View {
        Text("Results are observations to discuss with your vet - not a diagnosis.")
            .font(PetPawTypography.caption)
            .foregroundColor(PetPawColors.textTertiary)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
    }

    var analyseButton: some View {
        Button 
        {
            analyse()
        } label: {
            HStack {
                if isAnalyzing {
                    ProgressView()
                        .tint(.white)

                    Text("Analysing…")
                } else {
                    Image(systemName: "sparkles")
                    Text("Analyse with Core ML")
                }
            }
            .font(PetPawTypography.button)
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .foregroundColor(.white)
            .background(
                LinearGradient(
                    colors: [PetPawColors.primary, PetPawColors.successDark],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(16)
            .opacity(capturedImage == nil ? 0.5 : 1)
        }
        .disabled(capturedImage == nil || isAnalyzing)
    }

    func analyse() {
        isAnalyzing = true

        Task 
        {
            try? await Task.sleep(nanoseconds: 1_200_000_000)

            isAnalyzing = false
            showResult = true
        }
    }

    var resultCard: some View {
        VStack(spacing: Spacing.lg) {
            if let capturedImage = capturedImage 
            {
                Image(uiImage: capturedImage)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 220)
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            }

            VStack(spacing: Spacing.sm){
                Circle()
                    .fill(PetPawColors.primary.opacity(0.12))
                    .frame(width: 56, height: 56)
                    .overlay {
                        Image(systemName: selectedArea.icon)
                            .font(.system(size: 22))
                            .foregroundColor(PetPawColors.primary)
                    }

                Text("\(selectedArea.rawValue) check saved")
                    .font(PetPawTypography.h3)
                    .foregroundColor(PetPawColors.textPrimary)
            }
            .padding(Spacing.lg)
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: PetPawColors.shadowLight, radius: 8, x: 0, y: 4)

            Button 
            {
                reset()
            } label: {
                Text("Done")
                    .font(PetPawTypography.button)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(PetPawColors.primary)
                    .cornerRadius(16)
            }
        }
    }

    func reset() 
    {
        capturedImage = nil
        selectedArea = .skin
        showResult = false
    }
}

#Preview {
    ScrollView {
        HealthScanTab().padding(Spacing.lg)
    }
}
