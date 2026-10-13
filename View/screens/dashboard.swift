//
//  dashboard.swift
//  petpaw
//
//  Created by Piyumi Imalka on 2026-10-07.
//

import SwiftUI

struct dashboard: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showProfile = false
    @EnvironmentObject var petsViewModel: PetsViewModel
    @StateObject private var profileViewModel = ProfileViewModel()
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    var onSelectTab: (AppTab) -> Void = { _ in }

    var body: some View {
        ZStack {
           background

            ScrollView(showsIndicators: false) {
                VStack(spacing: Spacing.lg) {
                    header
                    petCard
                    quickActions
                    scheduleCard

                }
                .padding(.horizontal, Spacing.lg)
                .padding(.top, Spacing.sm)
                .padding(.bottom, Spacing.xl)
                .frame(maxWidth: 700)
            }
        }

        .sheet(isPresented: $showProfile) {
            UserProfileScreen()
        }
        .task {
             await loadProfile()
         }
    }

    private var background: some View {
        LinearGradient(
            gradient: Gradient(colors:[PetPawColors.primaryBg, Color.white]),
            startPoint: .top,
            endPoint: .bottom
        )

        .ignoresSafeArea()
    }

     private var header: some View {
        HStack(spacing: Spacing.md) {
            Button(action: {
                showProfile = true
            }) {
                ZStack{
                    Circle()
                        .fill(PetPawColors.primary.opacity(0.12))
                        .frame(width: 44, height: 44)

                    Image(systemName: "pawprint.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(PetPawColors.primary)
                }
            }

            .accessibilityLabel("Your profile")

            VStack(alignment: .leading, spacing: 2) {
                Text(greeting)
                    .font(PetPawTypography.bodySmall)
                    .foregroundColor(PetPawColors.textSecondary)
                Text(firstName)
                    .font(PetPawTypography.h2)
                    .foregroundColor(PetPawColors.textPrimary)
            }

            Spacer()

            Button(action: { onSelectTab(.reminders) }) {
                Image(systemName: "bell.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(PetPawColors.primary)
                    .frame(width: 44, height: 44)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: PetPawColors.shadowLight, radius: 6, x: 0, y: 3)
            }
            .accessibilityLabel("Reminders")
        }

        .padding(.top, Spacing.sm)
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())

        if hour < 12 {
            return "Good morning,"
        } else if hour < 17 {
            return "Good afternoon,"
        } else {
            return "Good evening,"
        }
    }

    private var firstName: String {
        let fullName = profileViewModel.profile?.fullName ?? ""
        return fullName.split(separator: " ").first.map(String.init) ?? "there"
    }

    @ViewBuilder
    private var petCard: some View {
        if let pet = petsViewModel.selectedPet {
            Button(action: { onSelectTab(.pets)}) {
                HStack(spacing: Spacing.md) {
                    petAvatar(for: pet)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(pet.name)
                            .font(PetPawTypography.h3)
                            .foregroundColor(PetPawColors.textPrimary)

                        Text(petSubtitle(for: pet))
                            .font(PetPawTypography.bodySmall)
                            .foregroundColor(PetPawColors.textSecondary)

                        Text("View profile")
                            .font(PetPawTypography.caption.weight(.semibold))
                            .foregroundColor(PetPawColors.primary)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(PetPawColors.textTertiary.opacity(0.6))
                }
                .padding(Spacing.md)
                .background(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(Color.white)
                )
                .shadow(color: PetPawColors.shadowLight, radius: 10, x: 0, y: 5)
            }
            .buttonStyle(.plain)
        } else {
            Button(action: { onSelectTab(.pets) }) {
                VStack(spacing: Spacing.sm) {
                    Image(systemName: "pawprint.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(PetPawColors.primary)
                    Text("Add your first pet")
                        .font(PetPawTypography.h3)
                        .foregroundColor(PetPawColors.textPrimary)
                    Text("Create a profile to start tracking their health")
                        .font(PetPawTypography.bodySmall)
                        .foregroundColor(PetPawColors.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(Spacing.lg)
                .background(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .strokeBorder(PetPawColors.primary, style: StrokeStyle(lineWidth: 2, dash: [6]))
                )
            }
            .buttonStyle(.plain)
        }
    }

    private func petAvatar(for pet: Pet) -> some View {
        ZStack {
            Circle()
                .fill(PetPawColors.primaryBg)
                .frame(width: 56, height: 56)

            if let photoURL = pet.photoURL, let image = UIImage(dataURLString: photoURL) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 56, height: 56)
                    .clipShape(Circle())
            } else {
                Image(systemName: "pawprint.fill")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(PetPawColors.primary)
            }
        }
    }

    private func petSubtitle(for pet: Pet) -> String {
        var subtitle = ""

        if let breed = pet.breed, !breed.isEmpty {
            subtitle = breed
        } else if !pet.species.isEmpty {
            subtitle = pet.species
        }

        if let age = pet.ageInYears {
            if !subtitle.isEmpty {
                subtitle += " · "
            }
            subtitle += "\(age) yrs"
        }

        if pet.weightKg > 0 {
            if !subtitle.isEmpty {
                subtitle += " · "
            }
            subtitle += String(format: "%.1f kg", pet.weightKg)
        }

        return subtitle
    }

    private var quickActions: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Quick actions")
                .font(PetPawTypography.h3)
                .foregroundColor(PetPawColors.textPrimary)

            LazyVGrid(columns: gridColumns, spacing: Spacing.sm) {
                QuickActionButton(icon: "viewfinder", title: "Scan Health", color: PetPawColors.primary) {
                    onSelectTab(.health)
                }
                QuickActionButton(icon: "plus.circle.fill", title: "Add Record", color: PetPawColors.attention) {
                    onSelectTab(.health)
                }
                QuickActionButton(icon: "scalemass.fill", title: "Weight", color: PetPawColors.info) {
                    onSelectTab(.pets)
                }
                QuickActionButton(icon: "bell.fill", title: "Reminders", color: PetPawColors.warning) {
                    onSelectTab(.reminders)
                }
            }
        }
    }

    private var gridColumns: [GridItem] {
        let count = horizontalSizeClass == .regular ? 4 : 2
        return Array(repeating: GridItem(.flexible(), spacing: Spacing.sm), count: count)
    }

    private var scheduleCard: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Today's schedule")
                .font(PetPawTypography.h3)
                .foregroundColor(PetPawColors.textPrimary)

            Button(action: { onSelectTab(.reminders) }) {
                HStack(spacing: Spacing.md) {
                    ZStack {
                        Circle()
                            .fill(PetPawColors.warning.opacity(0.15))
                            .frame(width: 48, height: 48)
                        Image(systemName: "calendar.badge.clock")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(PetPawColors.warning)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Feeding, medication & vet reminders")
                            .font(PetPawTypography.body.weight(.semibold))
                            .foregroundColor(PetPawColors.textPrimary)
                        Text("Coming soon")
                            .font(PetPawTypography.caption)
                            .foregroundColor(PetPawColors.textTertiary)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(PetPawColors.textTertiary.opacity(0.6))
                }
                .padding(Spacing.md)
                .background(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(Color.white)
                )
                .shadow(color: PetPawColors.shadowLight, radius: 10, x: 0, y: 5)
            }
.buttonStyle(.plain)
        }
    }

    private func loadProfile() async {
        guard let uid = authViewModel.authService.currentUser?.uid else { return }
        await profileViewModel.loadProfile(uid: uid)
    }
}

private struct QuickActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: Spacing.sm) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 48, height: 48)
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(color)
                }

                Text(title)
                    .font(PetPawTypography.caption.weight(.semibold))
                    .foregroundColor(PetPawColors.textPrimary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.white)
            )
            .shadow(color: PetPawColors.shadowLight, radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
    }
}

#Preview {
    dashboard()
        .environmentObject(AuthViewModel())
        .environmentObject(PetsViewModel())
}
