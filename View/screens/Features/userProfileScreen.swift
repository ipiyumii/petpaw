//
//  userProfileScreen.swift
//  petpaw
//
//  Created by Piyumi Imalka on 2026-10-08.
//

import SwiftUI

private enum ProfileField: Hashable {
    case fullName
    case phoneNumber
    case bio
}

struct UserProfileScreen: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel

    @StateObject private var viewModel = ProfileViewModel()

    @State private var selectedPhoto: UIImage?
    @State private var showPhotoPicker = false
    @State private var showSignOutConfirmation = false
    @State private var editingField: ProfileField?

    @FocusState private var focusedField: ProfileField?

    var body: some View {
        ZStack {
            PetPawColors.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                header

                if viewModel.isLoading {
                    ProgressView()
                        .tint(PetPawColors.primary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                } else if let errorMessage = viewModel.errorMessage,
                          viewModel.profile == nil {
                    ErrorState(message: errorMessage) {
                        Task {
                            await loadProfile()
                        }
                    }

                } else if viewModel.profile != nil {
                    profileContent
                }
            }
        }
        .sheet(isPresented: $showPhotoPicker) {
            selectImage(image: $selectedPhoto)
        }
        .task {
            await loadProfile()
        }
        .confirmationDialog(
            "Are you sure you want to sign out?",
            isPresented: $showSignOutConfirmation
        ) {
            Button("Sign Out", role: .destructive) {
                authViewModel.signOut()
            }

            Button("Cancel", role: .cancel) {
            }
        }
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

            Text("My Profile")
                .font(PetPawTypography.h3)
                .foregroundColor(PetPawColors.text)

            Spacer()

            Color.clear
                .frame(width: 36, height: 36)
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.md)
    }

    private var profileContent: some View {
        ScrollView {
            VStack(spacing: Spacing.lg) {
                profileHeader

                personalInformation

                if let errorMessage = viewModel.errorMessage {
                    errorMessageView(errorMessage)
                }

                buttons
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.bottom, Spacing.xl)
        }
    }

    private var profileHeader: some View {
        VStack(spacing: Spacing.sm) {
            ZStack(alignment: .bottom) {
                LinearGradient(
                    colors: [
                        PetPawColors.primary,
                        PetPawColors.successDark
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .frame(height: 120)
                .clipShape(
                    RoundedRectangle(cornerRadius: 24)
                )

                ProfileAvatarView(
                    photo: selectedPhoto,
                    name: viewModel.profile?.fullName ?? ""
                ) {
                    showPhotoPicker = true
                }
                .offset(y: 45)
            }
            .padding(.bottom, 45)

            Text(viewModel.profile?.fullName ?? "")
                .font(PetPawTypography.h3)
                .foregroundColor(PetPawColors.text)

            HStack(spacing: Spacing.xs) {
                Image(systemName: "envelope.fill")

                Text(viewModel.profile?.email ?? "")
            }
            .font(PetPawTypography.bodySmall)
            .foregroundColor(PetPawColors.textSecondary)

            if let date = viewModel.profile?.createdAt {
                Text("Member since \(date.formatted(.dateTime.month(.wide).year()))")
                    .font(PetPawTypography.badge)
                    .foregroundColor(PetPawColors.primary)
                    .padding(.horizontal, Spacing.sm)
                    .padding(.vertical, 6)
                    .background(PetPawColors.primary.opacity(0.12))
                    .clipShape(Capsule())
            }
        }
    }

    private var personalInformation: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Personal Information")
                .font(PetPawTypography.h3)
                .foregroundColor(PetPawColors.text)

            VStack(spacing: Spacing.sm) {
                profileRow(
                    icon: "person.fill",
                    color: PetPawColors.primary,
                    title: "Full name"
                ) {
                    if editingField == .fullName {
                        TextField("Full name", text: fullNameBinding)
                            .multilineTextAlignment(.trailing)
                            .focused($focusedField, equals: .fullName)
                            .onSubmit {
                                editingField = nil
                            }
                    } else {
                        Text(viewModel.profile?.fullName.isEmpty == false
                             ? viewModel.profile!.fullName
                             : "Not set")
                            .foregroundColor(PetPawColors.text)
                    }
                }

                Divider()

                profileRow(
                    icon: "phone.fill",
                    color: PetPawColors.attention,
                    title: "Phone number"
                ) {
                    if editingField == .phoneNumber {
                        TextField("Phone number", text: phoneNumberBinding)
                            .keyboardType(.phonePad)
                            .multilineTextAlignment(.trailing)
                            .focused($focusedField, equals: .phoneNumber)
                            .onSubmit {
                                editingField = nil
                            }
                    } else {
                        Text(viewModel.profile?.phoneNumber.isEmpty == false
                             ? viewModel.profile!.phoneNumber
                             : "Not set")
                            .foregroundColor(PetPawColors.text)
                    }
                }

                Divider()

                profileRow(
                    icon: "text.quote",
                    color: PetPawColors.info,
                    title: "Bio"
                ) {
                    if editingField == .bio {
                        TextField(
                            "Tell us about yourself",
                            text: bioBinding,
                            axis: .vertical
                        )
                        .lineLimit(3...5)
                        .focused($focusedField, equals: .bio)
                    } else {
                        Text(viewModel.profile?.bio.isEmpty == false
                             ? viewModel.profile!.bio
                             : "Not set")
                            .foregroundColor(PetPawColors.text)
                    }
                }
            }
            .padding(Spacing.Card.padding)
            .background(Color.white)
            .cornerRadius(Spacing.Card.cornerRadius)
        }
    }

    private func profileRow<Value: View>(
        icon: String,
        color: Color,
        title: String,
        @ViewBuilder value: () -> Value
    ) -> some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 32, height: 32)
                .background(color.opacity(0.12))
                .clipShape(Circle())

            Text(title)
                .font(PetPawTypography.bodySmall)
                .foregroundColor(PetPawColors.textSecondary)

            Spacer()

            value()
                .font(PetPawTypography.body)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if let field = fieldFor(title) {
                editingField = field
                focusedField = field
            }
        }
    }

    private func fieldFor(_ title: String) -> ProfileField? {
        switch title {
        case "Full name":
            return .fullName
        case "Phone number":
            return .phoneNumber
        case "Bio":
            return .bio
        default:
            return nil
        }
    }

    private func errorMessageView(_ message: String) -> some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(PetPawColors.danger)

            Text(message)
                .font(PetPawTypography.bodySmall)
                .foregroundColor(PetPawColors.danger)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Spacing.md)
        .background(PetPawColors.danger.opacity(0.1))
        .cornerRadius(12)
    }

    private var buttons: some View {
        VStack(spacing: Spacing.sm) {
            Button {
                handleSave()
            } label: {
                HStack {
                    if viewModel.isSaving {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Save Changes")
                    }
                }
                .font(PetPawTypography.button)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(PetPawColors.primary)
                .cornerRadius(12)
            }
            .disabled(
                !viewModel.hasUnsavedChanges ||
                viewModel.isSaving
            )

            Button {
                showSignOutConfirmation = true
            } label: {
                HStack {
                    Image(systemName: "arrow.right.square")
                    Text("Sign Out")
                }
                .font(PetPawTypography.button)
                .foregroundColor(PetPawColors.danger)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(PetPawColors.danger, lineWidth: 1)
                )
            }
        }
    }

    private var fullNameBinding: Binding<String> {
        Binding(
            get: {
                viewModel.profile?.fullName ?? ""
            },
            set: {
                viewModel.profile?.fullName = $0
            }
        )
    }

    private var phoneNumberBinding: Binding<String> {
        Binding(
            get: {
                viewModel.profile?.phoneNumber ?? ""
            },
            set: {
                viewModel.profile?.phoneNumber = $0
            }
        )
    }

    private var bioBinding: Binding<String> {
        Binding(
            get: {
                viewModel.profile?.bio ?? ""
            },
            set: {
                viewModel.profile?.bio = $0
            }
        )
    }

    private func handleSave() {
        Task {
            if await viewModel.save() {
                editingField = nil
                focusedField = nil
            }
        }
    }

    private func loadProfile() async {
        guard let uid = authViewModel.authService.currentUser?.uid else {
                    viewModel.errorMessage = "You need to be signed in to view your profile."
                    return
                }

        await viewModel.loadProfile(uid: uid)
    }
}

private struct ProfileAvatarView: View {
    let photo: UIImage?
    let name: String
    let onTap: () -> Void

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            if let photo {
                Image(uiImage: photo)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 96, height: 96)
                    .clipShape(Circle())
            } else {
                Circle()
                    .fill(PetPawColors.primaryBg)
                    .frame(width: 96, height: 96)
                    .overlay(
                        Text(initials)
                            .font(.system(size: 30, weight: .bold))
                            .foregroundColor(PetPawColors.primary)
                    )
            }

            Button {
                onTap()
            } label: {
                Image(systemName: "camera.fill")
                    .foregroundColor(.white)
                    .frame(width: 30, height: 30)
                    .background(PetPawColors.primary)
                    .clipShape(Circle())
            }
        }
    }

    private var initials: String {
        let names = name.split(separator: " ")

        if names.count >= 2 {
            return String(
                names.prefix(2).compactMap { $0.first }
            ).uppercased()
        }

        return names.first.map { String($0.prefix(1)).uppercased() } ?? "?"
    }
}

#Preview {
    UserProfileScreen()
        .environmentObject(AuthViewModel())
}
