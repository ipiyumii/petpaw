//
//  petProfile.swift
//  petpaw
//
//  Created by Piyumi Imalka on 2026-10-08.
//

import SwiftUI

private enum PetField:Hashable {
    case name
    case species
    case breed
    case dateOfBirth
    case sex
    case weight
}

struct PetProfile: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var petsViewModel: PetsViewModel
    @StateObject private var viewModel: PetProfileViewModel

    @State private var editingField: PetField?
    @State private var weightText = ""
    @FocusState private var focusedField: PetField?
    @State private var heroScale: CGFloat = 0.85
    @State private var heroOpacity: Double = 0

    init(pet: Pet, isNewPet: Bool) {
        _viewModel = StateObject(
            wrappedValue: PetProfileViewModel(pet: pet, isNewPet: isNewPet)
        )
    }

    var body: some View {
        ZStack {
            background

            VStack(spacing: 0) {
                header

                ScrollView(showsIndicators: false) {
                    VStack(spacing: Spacing.lg) {
                        heroSection
                            .scaleEffect(heroScale)
                            .opacity(heroOpacity)
                            .onAppear {
                                withAnimation(.spring(response: 0.6, dampingFraction: 0.75)) {
                                    heroScale = 1.0
                                    heroOpacity = 1.0
                                }
                            }

                        basicInfoCard
                        healthDetailsCard

                        if let errorMessage = viewModel.errorMessage {
                            errorBanner(errorMessage)
                        }

                        saveButton
                    }
                    .padding(.horizontal, Spacing.lg)
                    .padding(.bottom, Spacing.xl)
                }
            }
        }
        .sheet(isPresented: $viewModel.showPhotoPicker) {
            selectImage(image: $viewModel.selectedPhoto, isPresented: $viewModel.showPhotoPicker)
        }
        .navigationBarHidden(true)
        .onAppear {
            weightText = viewModel.pet.weightKg > 0
                ? String(format: "%.1f", viewModel.pet.weightKg)
                : ""
        }
        .onChange(of: weightText) { newValue in
            viewModel.pet.weightKg = PetProfile.parseWeight(newValue)
        }
    }

    static func parseWeight(_ text: String) -> Double {
        Double(text) ?? 0
    }

    private var background: some View {
        LinearGradient(
            gradient: Gradient(
                colors: [
                    PetPawColors.primaryBg,
                    Color.white
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    private var header: some View {
        HStack {
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(PetPawColors.primary)
                    .frame(width: 36, height: 36)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: PetPawColors.shadowLight, radius: 4, x: 0, y: 2)
            }
            .accessibilityLabel("Back")

            Spacer()

            Text("Pet Profile")
                .font(PetPawTypography.h3)
                .foregroundColor(PetPawColors.textPrimary)

            Spacer()

            Color.clear
                .frame(width: 36, height: 36)
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.md)
    }

    private var heroSection: some View {
        VStack(spacing: Spacing.md) {
            PetAvatarView(
                selectedPhoto: viewModel.selectedPhoto,
                photoURLString: viewModel.pet.photoURL,
                onTap: { 
                    viewModel.showPhotoPicker = true 
                }
            )

            Text(viewModel.pet.name.isEmpty ? "New Pet" : viewModel.pet.name)
                .font(PetPawTypography.h2)
                .foregroundColor(
                    viewModel.pet.name.isEmpty
                    ? PetPawColors.textTertiary
                    : PetPawColors.textPrimary
                )

            HStack(spacing: Spacing.sm) {
                if let breed = viewModel.pet.breed {
                    PetBadgeChip(icon: "pawprint.fill", text: breed, color: PetPawColors.primary)
                }

                if let age = viewModel.pet.ageInYears {
                    PetBadgeChip(
                        icon: "birthday.cake.fill",
                        text: "\(age) yrs",
                        color: PetPawColors.info
                    )
                }

                if viewModel.pet.sex != .unknown {
                    PetBadgeChip(
                        icon: "heart.fill",
                        text: viewModel.pet.sex.rawValue,
                        color: PetPawColors.attention
                    )
                }
            }
        }
        .padding(.top, Spacing.sm)
    }

    private var basicInfoCard: some View {
        PetInfoCard() {
            PetInfoRow(
                icon: "textformat",
                iconColor: PetPawColors.primary,
                label: "Name",
                isEditing: editingField == .name,
                onTap: { selectField(.name) }
            ) {
                if editingField == .name {
                    TextField("Name", text: nameBinding)
                        .foregroundColor(PetPawColors.textPrimary)
                        .focused($focusedField, equals: .name)
                        .onSubmit { editingField = nil }
                } else {
                    placeholderText(viewModel.pet.name)
                }
            }
            PetInfoRow(
                icon: "pawprint.fill",
                iconColor: PetPawColors.info,
                label: "Species",
                isEditing: editingField == .species,
                onTap: { selectField(.species) }
            ) {
                if editingField == .species {
                    TextField("e.g. Dog", text: speciesBinding)
                        .foregroundColor(PetPawColors.textPrimary)
                        .focused($focusedField, equals: .species)
                        .onSubmit { editingField = nil }
                } else {
                    placeholderText(viewModel.pet.species)
                }
            }

            PetInfoRow(
                icon: "star.circle.fill",
                iconColor: PetPawColors.warning,
                label: "Breed",
                isEditing: editingField == .breed,
                onTap: { selectField(.breed) }
            ) {
                if editingField == .breed {
                    TextField("Breed (optional)", text: breedBinding)
                        .foregroundColor(PetPawColors.textPrimary)
                        .focused($focusedField, equals: .breed)
                        .onSubmit { editingField = nil }
                } else {
                    placeholderText(viewModel.pet.breed ?? "")
                }
            }
        }
    }

    private var healthDetailsCard: some View {
        PetInfoCard() {
            PetInfoRow(
                icon: "calendar",
                iconColor: PetPawColors.attention,
                label: "Date of birth",
                isEditing: editingField == .dateOfBirth,
                onTap: { selectField(.dateOfBirth) }
            ) {
                if editingField == .dateOfBirth {
                    DatePicker(
                        "",
                        selection: dateOfBirthBinding,
                        displayedComponents: .date
                    )
                    .labelsHidden()
                } else if let date = viewModel.pet.dateOfBirth {
                    Text(date.formatted(date: .abbreviated, time: .omitted))
                } else {
                    Text("Not set")
                        .foregroundColor(PetPawColors.textTertiary)
                }
            }

            PetInfoRow(
                icon: "heart.fill",
                iconColor: PetPawColors.danger,
                label: "Sex",
                isEditing: editingField == .sex,
                onTap: { selectField(.sex) }
            ) {
                if editingField == .sex {
                    Picker("", selection: $viewModel.pet.sex) {
                        ForEach(PetSex.allCases, id: \.self) { sex in
                            Text(sex.rawValue).tag(sex)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 180)
                } else if viewModel.pet.sex != .unknown {
                    Text(viewModel.pet.sex.rawValue)
                } else {
                    Text("Not set")
                        .foregroundColor(PetPawColors.textTertiary)
                }
            }
            PetInfoRow(
                icon: "scalemass.fill",
                iconColor: PetPawColors.success,
                label: "Weight",
                isEditing: editingField == .weight,
                onTap: { selectField(.weight) }
            ) {
                if editingField == .weight {
                    TextField("kg", text: $weightText)
                        .foregroundColor(PetPawColors.textPrimary)
                        .keyboardType(.decimalPad)
                        .focused($focusedField, equals: .weight)
                        .onSubmit { editingField = nil }
                } else if viewModel.pet.weightKg > 0 {
                    Text(String(format: "%.1f kg", viewModel.pet.weightKg))
                } else {
                    Text("Not set")
                        .foregroundColor(PetPawColors.textTertiary)
                }
            }
        }
    }

    @ViewBuilder
    private func placeholderText(_ text: String) -> some View {
        if text.isEmpty {
            Text("Not set")
                .foregroundColor(PetPawColors.textTertiary)
        } else {
            Text(text)
        }
    }

    private func errorBanner(_ message: String) -> some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(PetPawColors.danger)
            Text(message)
                .font(PetPawTypography.bodySmall)
                .foregroundColor(PetPawColors.dangerDark)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Spacing.md)
        .background(PetPawColors.danger.opacity(0.1))
        .cornerRadius(12)
    }

    private var saveButton: some View {
        VStack(spacing: Spacing.sm) {
            Button(action: handleSave) {
            HStack {
                if viewModel.isSaving {
                    ProgressView().tint(.white)
                } else {
                    Image(systemName: "checkmark.circle.fill")
                    Text("Save")
                        .font(PetPawTypography.button)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .foregroundColor(.white)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [PetPawColors.primary, PetPawColors.successDark]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(14)
            .opacity(viewModel.hasAnyInput ? 1.0 : 0.5)
            .shadow(
                color: viewModel.hasAnyInput ? PetPawColors.primary.opacity(0.3) : .clear,
                radius: 10, x: 0, y: 5
            )
        }
        .disabled(!viewModel.hasAnyInput || viewModel.isSaving)
        .accessibilityHint("Double-tap to save this pet's profile")

        HStack {
            Image(systemName: "waveform.path.ecg")
            Text("View Health History")

            Spacer()

            Text("TODO")
                .font(PetPawTypography.caption)
                .foregroundColor(PetPawColors.textTertiary)
        }
        .font(PetPawTypography.button)
        .foregroundColor(PetPawColors.textTertiary)
        .frame(height: 54)
        .padding(.horizontal, Spacing.md)

        .overlay(
            RoundedRectangle(cornerRadius: 14).stroke(PetPawColors.border, lineWidth: 1.5)
        )
    }
    .padding(.top, Spacing.sm)
    }

    private var nameBinding: Binding<String> {
        Binding(
            get: { viewModel.pet.name },
            set: { viewModel.pet.name = $0 }
        )
    }

    private var speciesBinding: Binding<String> {
        Binding(
            get: { viewModel.pet.species },
            set: { viewModel.pet.species = $0 }
        )
    }

    private var breedBinding: Binding<String> {
        Binding(
            get: {
                viewModel.pet.breed ?? ""
            },
            set: {
                viewModel.pet.breed = $0.isEmpty ? nil : $0
            }
        )
    }

    private var dateOfBirthBinding: Binding<Date> {
        Binding(
            get: {
                viewModel.pet.dateOfBirth ?? Date()
            },
            set: {
                viewModel.pet.dateOfBirth = $0
            }
        )
    }

    private func selectField(_ field: PetField) {
        editingField = field
        focusedField = field
    }

    private func handleSave() {
        Task {
            if await viewModel.save() {
                editingField = nil
                focusedField = nil
                
                if viewModel.isNewPet {
                    petsViewModel.addPet(viewModel.pet)
                } else {
                    petsViewModel.replacePet(viewModel.pet)
                }
                
                dismiss()
            }
        }
    }
}

private struct PetAvatarView: View {
    let selectedPhoto: UIImage?
    let photoURLString: String?
    let onTap: () -> Void

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [PetPawColors.primaryLight, PetPawColors.primary]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 136, height: 136)

            photoContent
                .frame(width: 126, height: 126)
                .clipShape(Circle())
        }
            .shadow(color: PetPawColors.primary.opacity(0.25), radius: 14, x: 0, y: 8)

            Button(action: onTap) {
                Image(systemName: "camera.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(PetPawColors.primary)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 3))
            }
            .accessibilityLabel("Upload pet photo")
            .accessibilityHint("Double-tap to choose a photo from your library")
        }
    }

    @ViewBuilder
    private var photoContent: some View {
        if let selectedPhoto {
            Image(uiImage: selectedPhoto)
                .resizable()
                .scaledToFill()
        } else if let photoURLString, let image = UIImage(dataURLString: photoURLString) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
        } else {
            placeholder
        }
    }

    private var placeholder: some View {
        ZStack {
            Color.white

            Image(systemName: "pawprint.fill")
                .font(.system(size: 44))
                .foregroundColor(PetPawColors.primary.opacity(0.4))
        }
    }
}
    
private struct PetBadgeChip: View {
    let icon: String
    let text: String
    let color: Color
        
    var body: some View {
        HStack(spacing: Spacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .semibold))
            Text(text)
                .font(PetPawTypography.badge)
        }
        .foregroundColor(color)
        .padding(.horizontal, Spacing.sm)
        .padding(.vertical, 6)
        .background(color.opacity(0.12))
        .clipShape(Capsule())
    }
}

private struct PetInfoCard<Content: View>: View {
    let title: String?
    let content: Content

    init(
        title: String? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            if let title {
                Text(title)
                    .font(PetPawTypography.h3)
                    .foregroundColor(PetPawColors.textPrimary)
                    .padding(.leading, Spacing.xs)
            }

            VStack(spacing: Spacing.sm) {
                content
            }
        }
    }
}

private struct PetInfoRow<Value: View>: View {
    let icon: String
    let iconColor: Color
    let label: String
    let isEditing: Bool
    let onTap: () -> Void
    let value: Value

    init(
        icon: String,
        iconColor: Color,
        label: String,
        isEditing: Bool,
        onTap: @escaping () -> Void,
        @ViewBuilder value: () -> Value
    ) {
        self.icon = icon
        self.iconColor = iconColor
        self.label = label
        self.isEditing = isEditing
        self.onTap = onTap
        self.value = value()
    }

    var body: some View {
        Group {
            if isEditing {
               rowContent
            } else {
                rowContent
                    .contentShape(RoundedRectangle(cornerRadius: 20, style: .continuous)).onTapGesture { onTap() }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(label)
        .accessibilityHint("Double-tap to edit")
    }

    private var rowContent: some View {
        HStack(spacing: Spacing.md) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.12))
                    .frame(width: 40, height: 40)
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(iconColor)
            }

            Text(label)
                .font(PetPawTypography.body.weight(.bold))
                .foregroundColor(PetPawColors.textPrimary)

            Spacer(minLength: Spacing.sm)

            value
                .font(PetPawTypography.body)
                .foregroundColor(PetPawColors.textPrimary)
                .multilineTextAlignment(.trailing)
                .lineLimit(1)

            if !isEditing{
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(PetPawColors.textTertiary.opacity(0.4))
            }
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous).fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(isEditing ? PetPawColors.primary.opacity(0.4) : Color.clear, lineWidth: 1.5)
        )
        .shadow(
            color: isEditing ? PetPawColors.primary.opacity(0.15) : PetPawColors.shadowLight,
            radius: isEditing ? 12 : 6, x: 0, y: isEditing ? 6 : 2
        )
        .scaleEffect(isEditing ? 1.01 : 1.0).animation(.spring(response: 0.35, dampingFraction: 0.75), value: isEditing)
    }
}

#Preview("Blank") {
    PetProfile(
        pet: Pet(
            id: "new",
            ownerId: "user",
            name: "",
            species: "",
            breed: nil,
            dateOfBirth: nil,
            sex: .unknown,
            weightKg: 0,
            photoURL: nil
        ),
        isNewPet: true
    )
    .environmentObject(PetsViewModel())
}

#Preview("Filled") {
    PetProfile(
        pet: Pet(
            id: "1",
            ownerId: "user",
            name: "leo",
            species: "Dog",
            breed: "breed",
            dateOfBirth: Calendar.current.date(
                byAdding: .year,
                value: -3,
                to: Date()
            ) ?? Date(),
            sex: .male,
            weightKg: 24.5,
            photoURL: nil
        ),

        isNewPet: false
    )
        .environmentObject(PetsViewModel())
    }

