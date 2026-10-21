//
//  settings.swift
//  petpaw
//
//  Created by Piyumi Imalka on 2026-10-17.
//


import SwiftUI
import UserNotifications

struct Settings: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = ProfileViewModel()

    @State private var showProfile = false
    @State private var showSignOutConfirmation = false
    @State private var showAbout = false
    @State private var showPrivacyPolicy = false
    @State private var showPasswordResetAlert = false
    @State private var passwordResetMessage = ""

    @State private var notificationsEnabled = UserDefaults.standard.bool(
        forKey: constants.UserData.notificationsEnabled
    )

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [PetPawColors.primaryBg, Color.white],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .foregroundColor(PetPawColors.primary)
                            .frame(width: 36, height: 36)
                            .background(Color.white)
                            .clipShape(Circle())
                    }

                    Spacer()

                    Text("Settings")
                        .font(PetPawTypography.h3)
                        .foregroundColor(PetPawColors.textPrimary)

                    Spacer()

                    Color.clear.frame(width: 36, height: 36)
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.vertical, Spacing.md)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: Spacing.lg) {
                        Button {
                            showProfile = true
                        } label: {
                            VStack(spacing: Spacing.sm) {
                                Image(systemName: "person.crop.circle.fill")
                                    .font(.system(size: 60))
                                    .foregroundColor(PetPawColors.primary)

                                Text(viewModel.profile?.fullName ?? "")
                                    .font(PetPawTypography.h3)
                                    .foregroundColor(PetPawColors.textPrimary)

                                Text(viewModel.profile?.email ?? "")
                                    .font(PetPawTypography.bodySmall)
                                    .foregroundColor(PetPawColors.textPrimary)
                            }
                        }
                        .buttonStyle(.plain)

                        VStack(alignment: .leading, spacing: Spacing.sm) {
                            Text("Account")
                                .font(PetPawTypography.body.weight(.bold))

                            SettingsRow(
                                icon: "person.fill",
                                label: "Account info",
                                iconColor: PetPawColors.primary
                            ) {
                                showProfile = true
                            }

                            SettingsRow(
                                icon: "key.fill",
                                label: "Change password",
                                iconColor: PetPawColors.attention
                            ) {
//                                sendPasswordReset()
                            }
                        }

                        VStack(alignment: .leading, spacing: Spacing.sm) {
                            Text("Preferences").font(PetPawTypography.body.weight(.bold))

                            HStack {
                                Image(systemName: "bell.fill").foregroundColor(PetPawColors.info)

                                Text("Enable notifications").font(PetPawTypography.body)

                                Spacer()

                                Toggle("", isOn: $notificationsEnabled)
                                    .labelsHidden()
                                    .tint(PetPawColors.primary)
                                    .onChange(of: notificationsEnabled) { newValue in
                                        UserDefaults.standard.set(newValue, forKey: constants.UserData.notificationsEnabled)

                                        if newValue {
                                            UNUserNotificationCenter.current()
                                                .requestAuthorization(
                                                    options: [.alert, .sound, .badge]
                                                ) { 
                                                    granted, error in
                                                    if let error = error 
                                                    {
                                                        print("Notification permission error")
                                                    }
                                                }
                                        } else {
                                            UNUserNotificationCenter.current()
                                                .getPendingNotificationRequests { 
                                                    requests in
                                                    let ids = requests.map { 
                                                        request in
                                                        request.identifier
                                                    }

                                                    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
                                                }
                                        }
                                    }

                            }
                            .padding(Spacing.md)
                            .background(Color.white)
                            .cornerRadius(18)

                            SettingsRow(
                                icon: "circle.lefthalf.filled",
                                label: "Appearance",
                                iconColor: PetPawColors.textTertiary,
                                labelColor: PetPawColors.textTertiary,
                                trailingText: "Coming soon",
                                showChevron: false,
                                trailingTextColor: PetPawColors.textTertiary
                            )
                        }

                        VStack(alignment: .leading, spacing: Spacing.sm) {
                            Text("About").font(PetPawTypography.body.weight(.bold))

                            SettingsRow(
                                icon: "info.circle.fill",
                                label: "About PetPaw",
                                iconColor: PetPawColors.info
                            ) {
                                showAbout = true
                            }

                            SettingsRow(
                                icon: "checkmark.shield.fill",
                                label: "Privacy policy",
                                iconColor: PetPawColors.success
                            ) {
                                showPrivacyPolicy = true
                            }
                        }

                        SettingsRow(
                            icon: "arrow.right.square",
                            label: "Sign Out",
                            iconColor: PetPawColors.danger,
                            labelColor: PetPawColors.danger,
                            showChevron: false
                        ) {
                            showSignOutConfirmation = true
                        }
                    }
                    .padding(.horizontal, Spacing.lg)
                    .padding(.bottom, Spacing.xl)
                }
            }
        }
        .sheet(isPresented: $showProfile) 
        {
            UserProfileScreen()
        }
        .sheet(isPresented: $showAbout) {
            InfoSheet(
                title: "About PetPaw",
                text: """
                PetPaw helps you keep track of your pet's health, weight, medicine and vaccinations. You can also scan for visible signs of skin irritation and use Siri to log medicine.
                """
            )
        }
        .sheet(isPresented: $showPrivacyPolicy) {
            InfoSheet(
                title: "Privacy Policy",
                text: """
                Your pet and health data is stored in Firebase under your account.

                Health scans are analysed on your device and photos are not sent elsewhere for analysis.

                We don't share your data with third parties.
                """
            )
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
        .alert("Reset Password", isPresented: $showPasswordResetAlert) {
            Button("OK") {

            }
        } message: {
            Text(passwordResetMessage)
        }
    }

    private func loadProfile() async {
        if let uid = authViewModel.authService.currentUser?.uid 
        {
            await viewModel.loadProfile(uid: uid)
        }
    }

   private func sendPasswordReset() 
   {
   //TODO
   }
}

private struct SettingsRow: View {
    let icon: String
    let label: String
    let iconColor: Color
    var labelColor: Color = PetPawColors.textPrimary
    var trailingText: String?
    var showChevron = true
    var onTap: (() -> Void)?
    var  trailingTextColor: Color = PetPawColors.textPrimary


    var body: some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: icon)
                .foregroundColor(iconColor)
                .frame(width: 28)

            Text(label)
                .font(PetPawTypography.body)
                .foregroundColor(labelColor)

            Spacer()

            if let trailingText = trailingText {
                Text(trailingText)
                    .font(PetPawTypography.bodySmall)
                    .foregroundColor(PetPawColors.textTertiary)
            }

            if showChevron && onTap != nil {
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(PetPawColors.textTertiary)
            }
        }
        .padding(Spacing.md)
        .background(Color.white)
        .cornerRadius(18)
        .contentShape(Rectangle())
        .onTapGesture {
            if let onTap = onTap 
            {
                onTap()
            }
        }
    }
}

private struct InfoSheet: View {
    @Environment(\.dismiss) private var dismiss
    let title: String
    let text: String

    var body: some View {
        NavigationStack {
            ScrollView {
                Text(text)
                    .font(PetPawTypography.body)
                    .foregroundColor(PetPawColors.textPrimary)
                    .padding(Spacing.lg)
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing){
                    Button("Done") 
                    {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    Settings().environmentObject(AuthViewModel())
}
