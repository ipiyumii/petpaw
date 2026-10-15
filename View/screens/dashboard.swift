//
//  dashboard.swift
//  petpaw
//
//  Created by Piyumi Imalka on 2026-10-07.
//

import SwiftUI

struct dashboard: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var petsViewModel: PetsViewModel
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @State private var showProfile = false
    @StateObject private var profileViewModel = ProfileViewModel()
    @State private var latestObservation: HealthObservation?
    @State private var latestMedicationLog: String?

    var onSelectTab: (AppTab) -> Void = { _ in }
    var onScanHealth: () -> Void={}
    var onAddRecord:() -> Void={}

    var body: some View {
        ZStack {
           background

            ScrollView(showsIndicators: false) {
                VStack(spacing: Spacing.lg) {
                    header
                    medicationBanner
                    petCard
                    quickActions
                    recentActivityCard

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
             loadRecentActivity()
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

                        if let observation = latestObservation 
                        {
                            let isConcern = observation.condition.lowercased().contains("concern")

                            HStack(spacing: Spacing.xs) {
                                Text(isConcern ? "Mild concern" : "Healthy")
                                    .font(PetPawTypography.caption.weight(.semibold))
                                    .foregroundColor(isConcern ? PetPawColors.warning : PetPawColors.success)
                                    .padding(.horizontal, Spacing.sm)
                                    .padding(.vertical, 2)
                                    .background((isConcern ? PetPawColors.warning : PetPawColors.success).opacity(0.12))
                                    .clipShape(Capsule())

                                Text("Last check: \(relativeDate(observation.createdAt))")
                                    .font(PetPawTypography.caption)
                                    .foregroundColor(PetPawColors.textTertiary)
                            }
                        } else {
                            Text("View profile")
                                .font(PetPawTypography.caption.weight(.semibold))
                                .foregroundColor(PetPawColors.primary)
                        }

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

    @ViewBuilder
    private var medicationBanner: some View {
        if let pet = petsViewModel.selectedPet 
        {
            if let latestMedicationLog = latestMedicationLog 
            {
                HStack(spacing: Spacing.sm) {
                    Image(systemName: "pills.fill").foregroundColor(PetPawColors.warningDark)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("LAST MEDICINE LOGGED")
                            .font(PetPawTypography.caption.weight(.bold))
                            .foregroundColor(PetPawColors.warningDark)

                        Text(latestMedicationLog)
                            .font(PetPawTypography.bodySmall)
                            .foregroundColor(PetPawColors.textPrimary)
                    }

                    Spacer()
                }
                .padding(Spacing.md)
                .background(RoundedRectangle(cornerRadius: 18).fill(PetPawColors.warning.opacity(0.18)))
            } else {
                Button {
                    onSelectTab(.reminders)
                } label: {
                    HStack {
                        Image(systemName: "mic.fill").foregroundColor(PetPawColors.primary)

                        Text("Try: \"Hey Siri, log medicine for \(pet.name) in PetPaw\"")
                            .font(PetPawTypography.caption)
                            .foregroundColor(PetPawColors.textPrimary)

                        Spacer()
                    }
                    .padding(Spacing.md)
                    .background(RoundedRectangle(cornerRadius: 18).fill(PetPawColors.primary.opacity(0.1)))
                }
                .buttonStyle(.plain)
            }
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
                    onScanHealth()
                }
                QuickActionButton(icon: "plus.circle.fill", title: "Add Record", color: PetPawColors.attention) {
                    onAddRecord()
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

    private var recentActivityCard: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Recent Activity")
                .font(PetPawTypography.h3)
                .foregroundColor(PetPawColors.textPrimary)

            if latestObservation == nil && latestMedicationLog == nil {
                Button(action: onScanHealth) {
                    activityRow(
                        icon: "calendar.badge.clock",
                        iconColor: PetPawColors.warning,
                        title: "No activity yet",
                        subtitle: "Scan your pet's health or log medicine with Siri"
                    )
                }
                .buttonStyle(.plain)
            } else {
                if let observation = latestObservation {
                    let isConcern = observation.condition.lowercased().contains("concern")

                    Button(action: onScanHealth) {
                        activityRow(
                            icon: observation.area == "Eyes" ? "eye.fill" : "viewfinder",
                            iconColor: isConcern ? PetPawColors.warning : PetPawColors.success,
                            title: "Health scan · \(observation.area)",
                            subtitle: "\(isConcern ? "Mild concern" : "Looked normal") · \(relativeDate(observation.createdAt))"
                        )
                    }
                    .buttonStyle(.plain)
                }

                if let medication = latestMedicationLog {
                    Button(action: {
                        onSelectTab(.reminders)
                    }) {
                        activityRow(
                            icon: "pills.fill",
                            iconColor: PetPawColors.attention,
                            title: "Medicine logged",
                            subtitle: medication
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func activityRow(icon: String, iconColor: Color, title: String, subtitle: String ) -> some View {
        HStack(spacing: Spacing.md) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 48, height: 48)

                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(iconColor)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(PetPawTypography.body.weight(.semibold))
                    .foregroundColor(PetPawColors.textPrimary)

                Text(subtitle)
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

    private func loadProfile() async {
        guard let uid = authViewModel.authService.currentUser?.uid else { return }
        await profileViewModel.loadProfile(uid: uid)
    }

    private func relativeDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }

    private func loadRecentActivity() {
        guard let pet = petsViewModel.selectedPet else { return }
        latestObservation = HealthObservationService().fetchObservations(petId: pet.id).first
        latestMedicationLog = MedicationLogStore.fetchAll().first(where: { $0.hasPrefix(pet.name) })
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
