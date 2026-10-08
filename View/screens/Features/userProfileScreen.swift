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
    @State private var heroScale: CGFloat = 0.85
    @State private var heroOpacity: Double = 0
    @FocusState private var focusedField: ProfileField?

    var body: some View {
        ZStack {
            background

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
            isPresented: $showSignOutConfirmation,
            titleVisibility: .visible
        ) {
            Button("Sign Out", role: .destructive) {
                authViewModel.signOut()
            }

            Button("Cancel", role: .cancel) {
            }
        }
    }

    private var background: some View {
        LinearGradient(
            gradient: Gradient(colors: [PetPawColors.primaryBg, Color.white]),
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    private var header: some View {
        HStack {
            Button(action: { dismiss() }){
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
        ScrollView(showsIndicators: false) {
            VStack(spacing: Spacing.lg) {
                profileHeader
                    .scaleEffect(heroScale)
                    .opacity(heroOpacity)
                    .onAppear {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.75)) {
                            heroScale = 1.0
                            heroOpacity = 1.0
                        }
                    }

                detailCards

                if let errorMessage = viewModel.errorMessage {
                    errorBanner(errorMessage)
                }

                actionButtons
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.bottom, Spacing.xl)
        }
    }

    private var profileHeader: some View {
        VStack(spacing: Spacing.sm) {
            ZStack(alignment: .bottom) {
                LinearGradient(
                    gradient: Gradient(colors: [PetPawColors.primaryLight, PetPawColors.primary, PetPawColors.successDark]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .overlay(bannerDecoration)
                .frame(height: 150)
                .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))

                ProfileAvatarView(
                    selectedPhoto: selectedPhoto,
                    fullName: viewModel.profile?.fullName ?? "",
                    onTap: { showPhotoPicker = true }
                )
                .offset(y: 48)
            }
            .padding(.bottom, 48)

            Text(viewModel.profile?.fullName ?? "")
                .font(PetPawTypography.h3)
                .foregroundColor(PetPawColors.text)

            HStack(spacing: Spacing.xs) {
                Image(systemName: "envelope.fill").font(.system(size: 11))
                Text(viewModel.profile?.email ?? "").font(PetPawTypography.bodySmall)
            }
            .foregroundColor(PetPawColors.textSecondary)

            if let createdAt = viewModel.profile?.createdAt {
                PillBadge(
                    icon: "sparkles",
                    text: "Member since \(createdAt.formatted(.dateTime.month(.wide).year()))"
                )
            }
        }
    }

    private var bannerDecoration: some View {
        GeometryReader { geo in
            Circle()
                .fill(Color.white.opacity(0.12))
                .frame(width: 140, height: 140)
                .offset(x: geo.size.width - 60, y: -50)

            Circle()
                .fill(Color.white.opacity(0.08))
                .frame(width: 90, height: 90)
                .offset(x: -20, y: 40)
        }
        .clipped()
    }

    private var detailCards: some View {
        VStack(spacing: Spacing.sm) {
            ProfileDetailCard(
                icon: "person.fill",
                iconColor: PetPawColors.primary,
                label: "Full name",
                isEditing: editingField == .fullName,
                onTap: { selectField(.fullName) }
            ) {
                if editingField == .fullName {
                    TextField("Full name", text: fullNameBinding)
                        .focused($focusedField, equals: .fullName)
                        .onSubmit { editingField = nil }
                } else {
                    let name = viewModel.profile?.fullName ?? ""
                    Text(name.isEmpty ? "Not set" : name)
                        .foregroundColor(name.isEmpty ? PetPawColors.textTertiary : PetPawColors.text)
                }
            }

            ProfileDetailCard(
                icon: "phone.fill",
                iconColor: PetPawColors.attention,
                label: "Phone number",
                isEditing: editingField == .phoneNumber,
                onTap: { selectField(.phoneNumber) }
            ) {
                if editingField == .phoneNumber {
                    TextField("Phone number", text: phoneNumberBinding)
                        .keyboardType(.phonePad)
                        .focused($focusedField, equals: .phoneNumber)
                        .onSubmit { editingField = nil }
                } else {
                    let phone = viewModel.profile?.phoneNumber ?? ""
                    Text(phone.isEmpty ? "Not set" : phone)
                        .foregroundColor(phone.isEmpty ? PetPawColors.textTertiary : PetPawColors.text)
                }
            }

            ProfileBioCard(
                isEditing: editingField == .bio,
                onTap: { selectField(.bio) }
            ) {
                if editingField == .bio {
                    TextField("Tell us about yourself", text: bioBinding, axis: .vertical)
                        .lineLimit(3...5)
                        .focused($focusedField, equals: .bio)
                } else {
                    let bio = viewModel.profile?.bio ?? ""
                    Text(bio.isEmpty ? "Tap to write a short bio" : bio)
                        .foregroundColor(bio.isEmpty ? PetPawColors.textTertiary : PetPawColors.text)
                }
            }
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
        .cornerRadius(16)
    }

    private var actionButtons: some View {
        VStack(spacing: Spacing.sm) {
            Button(action: handleSave) {
                HStack {
                    if viewModel.isSaving {
                        ProgressView().tint(.white)
                    } else {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Save Changes")
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
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .opacity(viewModel.hasUnsavedChanges ? 1.0 : 0.5)
                .shadow(
                    color: viewModel.hasUnsavedChanges ? PetPawColors.primary.opacity(0.3) : .clear,
                    radius: 10, x: 0, y: 5
                )
            }
            .disabled(!viewModel.hasUnsavedChanges || viewModel.isSaving)
            .accessibilityHint("Double-tap to save your changes")

            Button(role: .destructive) {
                showSignOutConfirmation = true
            } label: {
                HStack(spacing: Spacing.xs) {
                    Image(systemName: "arrow.right.square")
                    Text("Sign Out")
                }
                .font(PetPawTypography.button)
                .foregroundColor(PetPawColors.danger)
                .padding(.vertical, Spacing.sm)
            }
            .accessibilityHint("Double-tap to sign out of your account")
        }
        .padding(.top, Spacing.sm)
    }

    private var fullNameBinding: Binding<String> {
        Binding(get: { viewModel.profile?.fullName ?? "" }, set: { viewModel.profile?.fullName = $0 })
    }

    private var phoneNumberBinding: Binding<String> {
        Binding(get: { viewModel.profile?.phoneNumber ?? "" }, set: { viewModel.profile?.phoneNumber = $0 })
    }

    private var bioBinding: Binding<String> {
        Binding(get: { viewModel.profile?.bio ?? "" }, set: { viewModel.profile?.bio = $0 })
    }

    private func selectField(_ field: ProfileField) {
        editingField = field
        focusedField = field
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
    let selectedPhoto: UIImage?
    let fullName: String
    let onTap: () -> Void

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 104, height: 104)

                photoContent
                    .frame(width: 96, height: 96)
                    .clipShape(Circle())
            }
            .shadow(color: Color.black.opacity(0.18), radius: 12, x: 0, y: 5)

            Button(action: onTap) {
                Image(systemName: "camera.fill")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 30, height: 30)
                    .background(PetPawColors.primary)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 3))
            }
            .accessibilityLabel("Change profile photo")
            .accessibilityHint("Double-tap to choose a photo from your library")
        }
    }

    @ViewBuilder
    private var photoContent: some View {
        if let selectedPhoto {
            Image(uiImage: selectedPhoto)
                .resizable()
                .scaledToFill()
        } else {
            LinearGradient(
                gradient: Gradient(colors: [PetPawColors.primaryBg, PetPawColors.primaryLight.opacity(0.3)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .overlay(
                Text(initials)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(PetPawColors.primary)
            )
        }
    }

    private var initials: String {
        let letters = fullName.split(separator: " ").prefix(2).compactMap { $0.first }
        return letters.isEmpty ? "?" : String(letters).uppercased()
    }
}

private struct PillBadge: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: Spacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .semibold))
            Text(text)
                .font(PetPawTypography.badge)
        }
        .foregroundColor(PetPawColors.primary)
        .padding(.horizontal, Spacing.sm)
        .padding(.vertical, 6)
        .background(PetPawColors.primary.opacity(0.12))
        .clipShape(Capsule())
    }
}

private struct ProfileDetailCard<Value: View>: View {
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
        HStack(spacing: Spacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 46, height: 46)
                Image(systemName: icon)
                    .font(.system(size: 19, weight: .semibold))
                    .foregroundColor(iconColor)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(label)
                    .font(PetPawTypography.caption)
                    .foregroundColor(PetPawColors.textSecondary)

                value
                    .font(PetPawTypography.body.weight(.semibold))
                    .foregroundColor(PetPawColors.text)
            }

            Spacer()

            if !isEditing {
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(PetPawColors.textTertiary.opacity(0.6))
            }
        }
        .padding(Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(isEditing ? iconColor.opacity(0.5) : Color.clear, lineWidth: 2)
        )
        .shadow(color: PetPawColors.shadowLight, radius: isEditing ? 14 : 7, x: 0, y: isEditing ? 7 : 3)
        .contentShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .onTapGesture { if !isEditing { onTap() } }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(label)
        .accessibilityHint("Double-tap to edit")
    }
}

private struct ProfileBioCard<Value: View>: View {
    let isEditing: Bool
    let onTap: () -> Void
    let value: Value

    init(isEditing: Bool, onTap: @escaping () -> Void, @ViewBuilder value: () -> Value) {
        self.isEditing = isEditing
        self.onTap = onTap
        self.value = value()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack(spacing: Spacing.sm) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(PetPawColors.info.opacity(0.15))
                        .frame(width: 36, height: 36)
                    Image(systemName: "quote.opening")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(PetPawColors.info)
                }

                Text("About Me")
                    .font(PetPawTypography.bodySmall.weight(.semibold))
                    .foregroundColor(PetPawColors.textSecondary)

                Spacer()

                if !isEditing {
                    Image(systemName: "pencil")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(PetPawColors.textTertiary.opacity(0.6))
                }
            }

            value
                .font(PetPawTypography.body)
                .foregroundColor(PetPawColors.text)
        }
        .padding(Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(isEditing ? PetPawColors.info.opacity(0.5) : Color.clear, lineWidth: 2)
        )
        .shadow(color: PetPawColors.shadowLight, radius: isEditing ? 14 : 7, x: 0, y: isEditing ? 7 : 3)
        .contentShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .onTapGesture { if !isEditing { onTap() } }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Bio")
        .accessibilityHint("Double-tap to edit")
    }
}

#Preview {
    UserProfileScreen()
        .environmentObject(AuthViewModel())
}
