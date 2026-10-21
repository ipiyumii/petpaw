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
    @State private var scanResult: HealthScanResult?
    @EnvironmentObject var petViewModel: PetsViewModel

    private let service : HealthAnalysisServiceProtocol = HealthAnalysisService()
    private let observationService = HealthObservationService()

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
            selectImage(image: $capturedImage, isPresented: $showLibraryPicker)
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
                        .foregroundColor(PetPawColors.textPrimary)
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
                    Text("Analyse my pet")
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
        guard let capturedImage = capturedImage else {
            return
        }

        isAnalyzing = true
        let startTime = Date()

        Task {
            let result = try? await service.analyze(capturedImage)
            let minimumduration = 4.0
            let elapsed = Date().timeIntervalSince(startTime)
            
            if elapsed < minimumduration
            {
                try? await Task.sleep(nanoseconds: UInt64((minimumduration-elapsed) * 1_000_000_000))
            }
            scanResult = result
            isAnalyzing = false
            showResult = true
        }
    }

    var resultCard: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            observationBanner

            if let capturedImage = capturedImage 
            {
        VStack(spacing: Spacing.xs) {
            Image(uiImage: capturedImage)
                .resizable()
                .scaledToFill()
                .frame(height: 200)
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

                Text("Scanned photo · \(selectedArea.rawValue)")
            .font(PetPawTypography.caption)
            .foregroundColor(PetPawColors.textTertiary)
        }
    }

        HStack(spacing: Spacing.sm) {
            resultPill(icon: "viewfinder", text: "Area: \(selectedArea.rawValue)")
        }

        detectionsSection
        recommendedActionsSection

        Button(action: saveToRecords) {
            Text("Save to records")
                .font(PetPawTypography.button)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(PetPawColors.primary)
                .cornerRadius(16)
            }
        }
    }


private var isConcern: Bool {
    if let result = scanResult 
    {
        return result.condition.lowercased().contains("concern")
    }
    return false
}

private var observationBanner: some View {
    HStack(alignment: .top, spacing: Spacing.sm) {
        Image(systemName: scanResult == nil ? "questionmark.circle.fill" :
            (isConcern ? "exclamationmark.triangle.fill" : "checkmark.circle.fill")).font(.system(size: 20))

            .foregroundColor(
                scanResult == nil ? PetPawColors.textTertiary : (isConcern ? PetPawColors.warning : PetPawColors.success)
            )

        VStack(alignment: .leading, spacing: 2) {
            if scanResult != nil 
            {
                Text(isConcern ?
                     "Possible \(selectedArea.rawValue.lowercased()) irritation" :
                     "\(selectedArea.rawValue) looks normal")
                    .font(PetPawTypography.body.weight(.semibold))
                    .foregroundColor(PetPawColors.textPrimary)

                Text("Observation · not a diagnosis")
                    .font(PetPawTypography.caption.weight(.semibold))
                    .foregroundColor(isConcern ? PetPawColors.warning : PetPawColors.success)

                if isConcern 
                {
                    Text("Mild redness or irritation may be present. Monitor for changes and consult your vet if it worsens.")
                        .font(PetPawTypography.caption)
                        .foregroundColor(PetPawColors.textPrimary)
                } else {
                    Text("No obvious signs of concern were noticed. Keep an eye out for any changes.")
                        .font(PetPawTypography.caption)
                        .foregroundColor(PetPawColors.textPrimary)
                }
            } else {
                Text("Automated analysis isn't available in this version yet. Share this photo with your vet to get it checked.")
                    .font(PetPawTypography.bodySmall)
                    .foregroundColor(PetPawColors.textPrimary)
            }
        }
    }
    .padding(Spacing.md)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(
        RoundedRectangle(cornerRadius: 18, style: .continuous)
            .fill(
                (scanResult == nil ? PetPawColors.textTertiary : (isConcern ? PetPawColors.warning : PetPawColors.success)).opacity(0.12)
            )
    )
}

private func resultPill(icon: String, text: String) -> some View {
    HStack(spacing: Spacing.xs) {
        Image(systemName: icon).font(.system(size: 11, weight: .semibold))
        Text(text).font(PetPawTypography.caption.weight(.semibold))
    }
    .foregroundColor(PetPawColors.primary)
    .padding(.horizontal, Spacing.sm)
    .padding(.vertical, 6)
    .background(PetPawColors.primary.opacity(0.12))
    .clipShape(Capsule())
}

private var detectionsSection: some View {
    VStack(alignment: .leading, spacing: Spacing.sm) {
        Text("Detections")
            .font(PetPawTypography.h3)
            .foregroundColor(PetPawColors.textPrimary)

        if let result = scanResult {
            let percent = Int(result.confidence * 100)

            HStack(spacing: Spacing.md) {
                ZStack {
                    Circle()
                        .fill(
                            (isConcern ? PetPawColors.warning : PetPawColors.success)
                                .opacity(0.12)
                        )
                        .frame(width: 44, height: 44)

                    Image(systemName: selectedArea.icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(isConcern ? PetPawColors.warning : PetPawColors.success)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("\(selectedArea.rawValue) · \(isConcern ? "possible irritation" : "looks normal")")
                        .font(PetPawTypography.body.weight(.semibold))
                        .foregroundColor(PetPawColors.textPrimary)

                    Text("\(percent)% confidence · Vision + Core ML")
                        .font(PetPawTypography.caption)
                        .foregroundColor(PetPawColors.textTertiary)
                }

                Spacer()

                Text("\(percent)%")
                    .font(PetPawTypography.caption.weight(.bold))
                    .foregroundColor(isConcern ? PetPawColors.warning : PetPawColors.success)
                    .padding(.horizontal, Spacing.sm)
                    .padding(.vertical, 4)
                    .background(
                        (isConcern ? PetPawColors.warning : PetPawColors.success).opacity(0.15)
                    )
                    .clipShape(Capsule())
            }
            .padding(Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous).fill(Color.white)
            )
            .shadow(color: PetPawColors.shadowLight, radius: 6, x: 0, y: 3)
        }
    }
}

private var recommendedActionsSection: some View {
    VStack(alignment: .leading, spacing: Spacing.sm){
        Text("Recommended actions")
            .font(PetPawTypography.h3)
            .foregroundColor(PetPawColors.textPrimary)

        ForEach(recommendedActions, id: \.self) { action in
            HStack(spacing: Spacing.sm) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(PetPawColors.success)

                Text(action)
                    .font(PetPawTypography.bodySmall)
                    .foregroundColor(PetPawColors.textPrimary)

                Spacer()
            }
            .padding(Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.white)
            )
            .shadow(color: PetPawColors.shadowLight, radius: 4, x: 0, y: 2)
        }
    }
}

private var recommendedActions: [String] {
    if isConcern 
    {
        return [
            "Keep the area clean and dry",
            "Avoid excessive scratching or licking",
            "Recheck in a few days and log a new scan",
            "Consult your vet if it persists or worsens"
        ]
    }

    return[
        "No action needed right now",
        "Keep up your regular grooming routine",
        "Recheck periodically or after any changes",
        "Log a new scan anytime something looks different"
    ]
}

private func saveToRecords() {
    if let petId = petViewModel.selectedPet?.id {
        observationService.save(
            petId: petId,
            area: selectedArea.rawValue,
            condition: scanResult?.condition ?? "unknown",
            confidence: scanResult?.confidence ?? 0,
            photo: capturedImage
        )
    }

    reset()
}


    func reset() 
    {
        capturedImage = nil
        selectedArea = .skin
        showResult = false
        scanResult = nil
    }
}

#Preview {
    ScrollView {
        HealthScanTab().padding(Spacing.lg)
    }
    .environmentObject(PetsViewModel())
}
