//
//  petProfile.swift
//  petpaw
//
//  Created by Piyumi Imalka on 2026-10-08.
//

import SwiftUI

private enum PetField {
    case name
    case species
    case breed
    case dateOfBirth
    case sex
    case weight
}

struct PetProfile: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: PetProfileViewModel

    @State private var editingField: PetField?
    @State private var weightText = ""
    @FocusState private var focusedField: PetField?

    init(pet: Pet) {
        _viewModel = StateObject(
            wrappedValue: PetProfileViewModel(pet: pet)
        )
    }

    var body: some View {
        ZStack {
            background

            VStack(spacing: 0) {
                header

                ScrollView {
                    VStack(spacing: Spacing.lg) {
                        heroSection
                        basicInfoCard
                        healthDetailsCard

                        if let error = viewModel.errorMessage {
                            errorBanner(error)
                        }

                        saveButton
                    }
                    .padding(.horizontal, Spacing.lg)
                    .padding(.bottom, Spacing.xl)
                }
            }
        }
        .sheet(isPresented: $viewModel.showPhotoPicker) {
            selectImage(image: $viewModel.selectedPhoto)
        }
        .navigationBarHidden(true)
        .onAppear {
            weightText = viewModel.pet.weightKg > 0
                ? String(format: "%.1f", viewModel.pet.weightKg)
                : ""
        }
        .onChange(of: weightText) { _, newValue in
            viewModel.pet.weightKg = Double(newValue) ?? 0
        }
    }

    private var background: some View {
        LinearGradient(
            colors: [
                PetPawColors.primaryBg,
                PetPawColors.primary.opacity(0.08)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    private var header: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(PetPawColors.primary)
                    .frame(width: 36, height: 36)
                    .background(Color.white)
                    .clipShape(Circle())
            }

            Spacer()

            Text("Pet Profile")
                .font(PetPawTypography.h3)

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
                photoURLString: viewModel.pet.photoURL
            ) {
                viewModel.showPhotoPicker = true
            }

            Text(viewModel.pet.name.isEmpty ? "New Pet" : viewModel.pet.name)
                .font(PetPawTypography.h2)
                .foregroundColor(
                    viewModel.pet.name.isEmpty
                    ? PetPawColors.textTertiary
                    : PetPawColors.text
                )

            HStack {
                if let breed = viewModel.pet.breed, !breed.isEmpty {
                    PetBadgeChip(
                        icon: "pawprint.fill",
                        text: breed,
                        color: PetPawColors.primary
                    )
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
        PetInfoCard(title: "Basic Information") {
            infoRow(
                icon: "textformat",
                color: PetPawColors.primary,
                label: "Name"
            ) {
                if editingField == .name {
                    TextField("Name", text: $viewModel.pet.name)
                        .multilineTextAlignment(.trailing)
                        .focused($focusedField, equals: .name)
                } else {
                    Text(viewModel.pet.name.isEmpty ? "Not set" : viewModel.pet.name)
                        .foregroundColor(
                            viewModel.pet.name.isEmpty
                            ? PetPawColors.textTertiary
                            : PetPawColors.text
                        )
                }
            }
            .onTapGesture {
                editingField = .name
                focusedField = .name
            }

            Divider()

            infoRow(
                icon: "pawprint.fill",
                color: PetPawColors.info,
                label: "Species"
            ) {
                if editingField == .species {
                    TextField("e.g. Dog", text: $viewModel.pet.species)
                        .multilineTextAlignment(.trailing)
                        .focused($focusedField, equals: .species)
                } else {
                    Text(
                        viewModel.pet.species.isEmpty
                        ? "Not set"
                        : viewModel.pet.species
                    )
                    .foregroundColor(
                        viewModel.pet.species.isEmpty
                        ? PetPawColors.textTertiary
                        : PetPawColors.text
                    )
                }
            }
            .onTapGesture {
                editingField = .species
                focusedField = .species
            }

            Divider()

            infoRow(
                icon: "star.circle.fill",
                color: PetPawColors.warning,
                label: "Breed"
            ) {
                if editingField == .breed {
                    TextField("Breed", text: breedBinding)
                        .multilineTextAlignment(.trailing)
                        .focused($focusedField, equals: .breed)
                } else {
                    Text(viewModel.pet.breed ?? "Not set")
                        .foregroundColor(
                            viewModel.pet.breed == nil
                            ? PetPawColors.textTertiary
                            : PetPawColors.text
                        )
                }
            }
            .onTapGesture {
                editingField = .breed
                focusedField = .breed
            }
        }
    }

    private var healthDetailsCard: some View {
        PetInfoCard(title: "Health Details") {
            infoRow(
                icon: "calendar",
                color: PetPawColors.attention,
                label: "Date of birth"
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
            .onTapGesture {
                editingField = .dateOfBirth
            }

            Divider()

            infoRow(
                icon: "heart.fill",
                color: PetPawColors.danger,
                label: "Sex"
            ) {
                if editingField == .sex {
                    Picker("", selection: $viewModel.pet.sex) {
                        ForEach(PetSex.allCases, id: \.self) { sex in
                            Text(sex.rawValue).tag(sex)
                        }
                    }
                    .pickerStyle(.segmented)
                } else {
                    Text(
                        viewModel.pet.sex == .unknown
                        ? "Not set"
                        : viewModel.pet.sex.rawValue
                    )
                    .foregroundColor(
                        viewModel.pet.sex == .unknown
                        ? PetPawColors.textTertiary
                        : PetPawColors.text
                    )
                }
            }
            .onTapGesture {
                editingField = .sex
            }

            Divider()

            infoRow(
                icon: "scalemass.fill",
                color: PetPawColors.success,
                label: "Weight"
            ) {
                if editingField == .weight {
                    TextField("kg", text: $weightText)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .focused($focusedField, equals: .weight)
                } else if viewModel.pet.weightKg > 0 {
                    Text(String(format: "%.1f kg", viewModel.pet.weightKg))
                } else {
                    Text("Not set")
                        .foregroundColor(PetPawColors.textTertiary)
                }
            }
            .onTapGesture {
                editingField = .weight
                focusedField = .weight
            }
        }
    }

    private func infoRow<Content: View>(
        icon: String,
        color: Color,
        label: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 30)

            Text(label)
                .foregroundColor(PetPawColors.textSecondary)

            Spacer()

            content()
        }
        .font(PetPawTypography.body)
        .padding(.vertical, 6)
    }

    private func errorBanner(_ message: String) -> some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
            Text(message)
        }
        .foregroundColor(PetPawColors.danger)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(PetPawColors.danger.opacity(0.1))
        .cornerRadius(12)
    }

    private var saveButton: some View {
        Button {
            handleSave()
        } label: {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                Text("Save")
            }
            .font(PetPawTypography.button)
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .foregroundColor(.white)
            .background(PetPawColors.primary)
            .cornerRadius(14)
        }
        .disabled(!viewModel.hasAnyInput)
        .opacity(viewModel.hasAnyInput ? 1 : 0.5)
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

    private func handleSave() {
        if viewModel.save() {
            editingField = nil
            focusedField = nil
        }
    }
}

private struct PetAvatarView: View {
    let selectedPhoto: UIImage?
    let photoURLString: String?
    let onTap: () -> Void

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            photoContent
                .frame(width: 126, height: 126)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(PetPawColors.primary, lineWidth: 4)
                )

            Button(action: onTap) {
                Image(systemName: "camera.fill")
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(PetPawColors.primary)
                    .clipShape(Circle())
            }
        }
    }

    @ViewBuilder
    private var photoContent: some View {
        if let selectedPhoto {
            Image(uiImage: selectedPhoto)
                .resizable()
                .scaledToFill()
        } else if let photoURLString,
                  let url = URL(string: photoURLString) {
            AsyncImage(url: url) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                placeholder
            }
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
        HStack {
            Image(systemName: icon)
            Text(text)
        }
        .font(.caption)
        .foregroundColor(color)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(color.opacity(0.12))
        .clipShape(Capsule())
    }
}

private struct PetInfoCard<Content: View>: View {
    let title: String
    let content: Content

    init(
        title: String,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text(title)
                .font(PetPawTypography.h3)

            VStack(spacing: Spacing.sm) {
                content
            }
            .padding()
            .background(Color.white)
            .cornerRadius(Spacing.Card.cornerRadius)
        }
    }
}

#Preview("Blank") {
    PetProfile(
        pet: Pet(
            id: "new",
            name: "",
            species: "",
            breed: nil,
            dateOfBirth: nil,
            sex: .unknown,
            weightKg: 0,
            photoURL: nil
        )
    )
}

#Preview("Filled") {
    PetProfile(
        pet: Pet(
            id: "1",
            name: "Puffy",
            species: "Dog",
            breed: "Shih tzu",
            dateOfBirth: Calendar.current.date(
                byAdding: .year,
                value: -3,
                to: Date()
            ),
            sex: .male,
            weightKg: 24.5,
            photoURL: nil
        )
    )
}
