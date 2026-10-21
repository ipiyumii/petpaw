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
    @StateObject private var profileViewModel = ProfileViewModel()
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    // @State private var showProfile = false
    @State private var latestObservation: HealthObservation?
    @State private var latestMedReminder: Reminder?
    @State private var showSettings = false

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
                    todaysScheduleCard
                    recentActivityCard

                }
                .padding(.horizontal, Spacing.lg)
                .padding(.top, Spacing.sm)
                .padding(.bottom, Spacing.xl)
                .frame(maxWidth: 700)
            }
        }

        .sheet(isPresented: $showSettings) {
            Settings()
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
                showSettings = true
            }) {
                ZStack{
                    Circle()
                        .fill(PetPawColors.primary.opacity(0.12))
                        .frame(width: 44, height: 44)

                    Image(systemName: "person.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(PetPawColors.primary)
                }
            }

            .accessibilityLabel("Settings")

            VStack(alignment: .leading, spacing: 2) {
                Text(greeting)
                    .font(PetPawTypography.bodySmall)
                    .foregroundColor(PetPawColors.textPrimary)
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
            VStack(spacing: 0) {
                Button(action: { onSelectTab(.pets)}) {
                    HStack(spacing: Spacing.md) {
                        petAvatar(for: pet)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(pet.name)
                                .font(PetPawTypography.h3)
                                .foregroundColor(PetPawColors.textPrimary)

                            Text(petSubtitle(for: pet))
                                .font(PetPawTypography.bodySmall)
                                .foregroundColor(PetPawColors.textPrimary)

                            HStack(spacing: 2) {
                                Text("View profile")
                                    .font(PetPawTypography.caption.weight(.semibold))
                                    .foregroundColor(PetPawColors.primary)
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(PetPawColors.primary)
                            }
                        }

                        Spacer()
                    }
                    .padding(Spacing.md)
                }
                .buttonStyle(PressableStyle())

                if let latestObservation 
                {
                    let isConcern = latestObservation.condition.lowercased().contains("concern")
                    Divider().padding(.horizontal, Spacing.md)

                    HStack {
                        HStack(spacing: Spacing.xs) {
                            Image(systemName: isConcern ? "exclamationmark.triangle.fill" : "checkmark.circle.fill")
                                .font(.system(size: 12, weight: .semibold))
                            Text(isConcern ? "Mild concern" : "Healthy")
                                .font(PetPawTypography.caption.weight(.semibold))
                        }
                        .foregroundColor(isConcern ? PetPawColors.warning : PetPawColors.success)
                        .padding(.horizontal, Spacing.sm)
                        .padding(.vertical, 4)
                        .background((isConcern ? PetPawColors.warning : PetPawColors.success).opacity(0.12))
                        .clipShape(Capsule())

                        Spacer()

                        Text("Last check: \(relativeDate(latestObservation.createdAt))")
                            .font(PetPawTypography.caption)
                            .foregroundColor(PetPawColors.textTertiary)
                    }
                    .padding(.horizontal, Spacing.md)
                    .padding(.vertical, Spacing.sm)
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(Color.white)
            )
            .shadow(color: PetPawColors.shadowLight, radius: 10, x: 0, y: 5)
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
                        .foregroundColor(PetPawColors.textPrimary)
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
        if let pet = petsViewModel.selectedPet {
            if let latestMedReminder = latestMedReminder {
                HStack(spacing: Spacing.sm) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.4))
                            .frame(width: 36, height: 36)

                        Image(systemName: "pills.fill")
                            .foregroundColor(PetPawColors.warningDark)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("LAST MEDICINE LOGGED")
                            .font(PetPawTypography.caption.weight(.bold))
                            .foregroundColor(PetPawColors.warningDark)

                        Text(latestMedReminder.title)
                            .font(PetPawTypography.bodySmall.weight(.semibold))
                            .foregroundColor(PetPawColors.textPrimary)
                    }

                    Spacer()
                }
                .padding(Spacing.md)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(PetPawColors.warning.opacity(0.18))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(PetPawColors.warning.opacity(0.4), lineWidth: 1)
                )
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
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(PetPawColors.primary.opacity(0.1))
                    )
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
        var parts: [String] = []
        if let breed = pet.breed, !breed.isEmpty {
            parts.append(breed)
        } else if !pet.species.isEmpty {
            parts.append(pet.species)
        }
        if let age = pet.ageInYears { parts.append("\(age) yrs") }
        if pet.weightKg > 0 { parts.append(String(format: "%.1f kg", pet.weightKg)) }
        return parts.joined(separator: " · ")
    }

    private var quickActions: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Quick actions")
                .font(PetPawTypography.h3)
                .foregroundColor(PetPawColors.textSecondary)

            LazyVGrid(columns: gridColumns, spacing: Spacing.sm) {
                QuickActionButton(icon: "viewfinder", title: "Scan", color: PetPawColors.primary) {
                    onScanHealth()
                }
                QuickActionButton(icon: "plus.circle.fill", title: "Record", color: PetPawColors.attention) {
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
        return Array(repeating: GridItem(.flexible(), spacing: Spacing.sm), count: 4)
    }

private var todaysScheduleCard: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                Text("Today's schedule")
                    .font(PetPawTypography.h3)
                    .foregroundColor(PetPawColors.textPrimary)
                Spacer()
                Button(action: { onSelectTab(.reminders) }) {
                    Text("See all")
                        .font(PetPawTypography.bodySmall.weight(.semibold))
                        .foregroundColor(PetPawColors.primary)
                }
            }

            if let latestMedReminder {
                Button(action: { onSelectTab(.reminders) }) {
                    activityRow(
                        icon: "pills.fill",
                        iconColor: PetPawColors.attention,
                        title: latestMedReminder.title,
                        subtitle: "\(latestMedReminder.isCompleted ? "Given" : "Due") · \(relativeDate(latestMedReminder.date))",
                        status: latestMedReminder.isCompleted ? dashboard.ActivityStatus.done : dashboard.ActivityStatus.alert
                    )
                }
                .buttonStyle(PressableStyle())
            } else {
                Button(action: { onSelectTab(.reminders) }) {
                    activityRow(
                        icon: "mic.fill",
                        iconColor: PetPawColors.primary,
                        title: "No medicine logged yet",
                        subtitle: "Try \"Hey Siri, log medicine for \(petsViewModel.selectedPet?.name ?? "your pet") in PetPaw\"",
                        status: dashboard.ActivityStatus.chevron
                    )
                }
                .buttonStyle(PressableStyle())
            }
        }
    }

    private var recentActivityCard: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                Text("Recent Activity")
                    .font(PetPawTypography.h3)
                    .foregroundColor(PetPawColors.textPrimary)
                Spacer()
                Button(action: { onSelectTab(.reminders) }) 
                {
                    Text("See all")
                        .font(PetPawTypography.bodySmall.weight(.semibold))
                        .foregroundColor(PetPawColors.primary)
                }
            }

            if latestObservation == nil && latestMedReminder == nil {
                Button(action: onScanHealth) {
                    activityRow(
                        icon: "calendar.badge.clock",
                        iconColor: PetPawColors.warning,
                        title: "No activity yet",
                        subtitle: "Scan your pet's health or log medicine with Siri",
                        status: dashboard.ActivityStatus.chevron
                    )
                }
                .buttonStyle(PressableStyle())
            } else {
                if let latestObservation {
                    let isConcern = latestObservation.condition.lowercased().contains("concern")
                    Button(action: onScanHealth){
                        activityRow(
                            icon: latestObservation.area == "Eyes" ? "eye.fill" : "viewfinder",
                            iconColor: isConcern ? PetPawColors.warning : PetPawColors.success,
                            title: "Health scan · \(latestObservation.area)",
                            subtitle: "\(isConcern ? "Mild concern" : "Looked normal") · \(relativeDate(latestObservation.createdAt))",
                            status: isConcern ? dashboard.ActivityStatus.alert : dashboard.ActivityStatus.done
                        )
                    }
                    .buttonStyle(PressableStyle())
                }

                if let medication = latestMedReminder {
    Button(action: {
        onSelectTab(.reminders)
    }) {
        activityRow(
            icon: "pills.fill",
            iconColor: PetPawColors.attention,
            title: medication.title,
            subtitle: "\(medication.isCompleted ? "Given" : "Due") · \(relativeDate(medication.date))",
            status: medication.isCompleted ? dashboard.ActivityStatus.done : dashboard.ActivityStatus.alert
        )
    }
    .buttonStyle(PressableStyle())
}
            }
        }
    }

    enum ActivityStatus {
        case done, alert, chevron
    }

    private func activityRow(icon: String, iconColor: Color, title: String, subtitle: String, status: ActivityStatus) -> some View {
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

            if status == .done 
            {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(PetPawColors.success)
            } else if status == .alert {
                Image(systemName: "bell.fill")
                    .font(.system(size: 18))
                    .foregroundColor(PetPawColors.warning)
            } else {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(PetPawColors.textTertiary.opacity(0.6))
            }
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
        latestMedReminder = ReminderService().fetchAll(petId: pet.id).first(where: { $0.type == "meds" })
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
        .buttonStyle(PressableStyle())
        .accessibilityLabel(title)
    }
}

    private struct PressableStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View 
        {
            configuration.label
                .scaleEffect(configuration.isPressed ? 0.97 : 1)
                .opacity(configuration.isPressed ? 0.9 : 1)
                .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
        }
    }

#Preview {
    dashboard()
        .environmentObject(AuthViewModel())
        .environmentObject(PetsViewModel())
}
