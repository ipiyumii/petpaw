//
//  petHealthHistory.swift
//  petpaw
//
//  Created by Piyumi Imalka on 2026-10-22.
//

import SwiftUI

struct PetHealthHistory: View {
    @Environment(\.dismiss) private var dismiss
    let pet: Pet

    @State private var observations: [HealthObservation] = []
    @State private var weightEntries: [WeightEntry] = []
    @State private var selectedTab: HistoryTab = .all
    @State private var selectedObservation: HealthObservation?

    private enum HistoryTab: String, CaseIterable {
        case all = "All"
        case observations = "Observations"
        case weight = "Weight"
    }

    private enum HistoryCategory {
        case observation
        case weight
    }

    private struct HistoryItem: Identifiable {
        let id: String
        let category: HistoryCategory
        let icon: String
        let iconColor: Color
        let title: String
        let date: Date
        let badgeText: String
        let badgeColor: Color
        let observation: HealthObservation?
    }

    private var items: [HistoryItem] {
        var history: [HistoryItem] = []

        for observation in observations {
            let isConcern = observation.condition.lowercased().contains("concern")

            let item = HistoryItem(
                id: observation.id,
                category: .observation,
                icon: icon(forArea: observation.area),
                iconColor: isConcern ? PetPawColors.warning : PetPawColors.success,
                title: "\(observation.area) check",
                date: observation.createdAt,
                badgeText: isConcern ? "Mild concern" : "Normal",
                badgeColor: isConcern ? PetPawColors.warning : PetPawColors.success,
                observation: observation
            )
            history.append(item)
        }

        for entry in weightEntries {
            let item = HistoryItem(
                id: entry.id,
                category: .weight,
                icon: "scalemass.fill",
                iconColor: PetPawColors.attention,
                title: "Weight update",
                date: entry.date,
                badgeText: String(format: "%.1f kg", entry.weightKg),
                badgeColor: PetPawColors.attention,
                observation: nil
            )
            history.append(item)
        }
        history.sort { $0.date > $1.date }

        if selectedTab == .observations {
            return history.filter { $0.category == .observation }
        } else if selectedTab == .weight {
            return history.filter { $0.category == .weight }
        }
        return history
    }

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [PetPawColors.primaryBg, Color.white]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                header
                tabChips

                ScrollView(showsIndicators: false) {
                    VStack(spacing: Spacing.sm) {
                        if items.isEmpty {
                            emptyState
                        } else {
                            ForEach(items) { item in
                                itemRow(item)
                            }
                        }
                    }
                    .padding(Spacing.lg)
                }
            }
        }
        .sheet(item: $selectedObservation) { observation in
            ObservationDetailSheet(observation: observation)
        }
        .onAppear {
            loadHistory()
        }
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
            Text("Health History").font(PetPawTypography.h3).foregroundColor(PetPawColors.textPrimary)
            Spacer()

            Color.clear.frame(width: 36, height: 36)
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.md)
    }

    private var tabChips: some View {
        HStack(spacing: Spacing.sm) {
            ForEach(HistoryTab.allCases, id: \.self) { tab in
                Button(action: {
                    selectedTab = tab
                }) {
                    Text(tab.rawValue)
                        .font(PetPawTypography.caption.weight(.bold))
                        .foregroundColor(selectedTab == tab ? .white : PetPawColors.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Spacing.sm)
                        .background(selectedTab == tab ? PetPawColors.primary : Color.white)
                        .overlay(
                            Capsule().stroke(
                                selectedTab == tab ? Color.clear : PetPawColors.primary.opacity(0.4),
                                lineWidth: 1
                            )
                        )
                    .clipShape(Capsule())
                }
            }
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.bottom, Spacing.sm)
    }

    private func itemRow(_ item: HistoryItem) -> some View {
        Button(action: {
            if item.category == .observation {
                selectedObservation = item.observation
            }
        }) {
            HStack(spacing: Spacing.md) {
                ZStack {
                    Circle()
                        .fill(item.iconColor.opacity(0.12))
                        .frame(width: 42, height: 42)

                    Image(systemName: item.icon)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(item.iconColor)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(item.title)
                        .font(PetPawTypography.body.weight(.semibold))
                        .foregroundColor(PetPawColors.textPrimary)

                    Text(item.date.formatted(date: .abbreviated, time: .omitted))
                        .font(PetPawTypography.caption)
                        .foregroundColor(PetPawColors.textPrimary)
                }

                Spacer()

                Text(item.badgeText)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(item.badgeColor)
                    .padding(.horizontal, Spacing.sm)
                    .padding(.vertical, 4)
                    .background(item.badgeColor.opacity(0.14))
                    .clipShape(Capsule())
            }
            .padding(Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous).fill(Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(PetPawColors.borderLight, lineWidth: 1)
            )
            .shadow(color: PetPawColors.shadowLight, radius: 6, x: 0, y: 2)
        }
        .buttonStyle(.plain)
        .disabled(item.category == .weight)
    }

    private var emptyState: some View {
        VStack(spacing: Spacing.sm) {
            Image(systemName: "clock.badge.questionmark")
                .font(.system(size: 36))
                .foregroundColor(PetPawColors.textTertiary)

            Text("No health history yet")
                .font(PetPawTypography.body)
                .foregroundColor(PetPawColors.textPrimary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }

    private func icon(forArea area: String) -> String {
        switch area {
        case "Skin":
            return "viewfinder"
        case "Eyes":
            return "eye.fill"
        case "Ears":
            return "ear.fill"
        case "Teeth":
            return "face.smiling.fill"
        case "Paw":
            return "pawprint.fill"
        default:
            return "plus.circle.fill"
        }
    }

    private func loadHistory() {
        observations = HealthObservationService().fetchObservations(petId: pet.id)
        weightEntries = WeightService().fetchAll(petId: pet.id)
    }
}

private struct ObservationDetailSheet: View {
    @Environment(\.dismiss) private var dismiss
    let observation: HealthObservation

    private var isConcern: Bool {
        observation.condition.lowercased().contains("concern")
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    if let photo = observation.photo {
                        Image(uiImage: photo)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 220)
                            .frame(maxWidth: .infinity)
                            .clipShape(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                            )
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(observation.area) check")
                            .font(PetPawTypography.h2)
                            .foregroundColor(PetPawColors.textPrimary)

                        Text(observation.createdAt.formatted(date: .long, time: .shortened))
                            .font(PetPawTypography.caption)
                            .foregroundColor(PetPawColors.textPrimary)
                    }

                    HStack(spacing: Spacing.sm) {
                        Text(isConcern ? "Mild concern" : "Normal")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(isConcern ? PetPawColors.warning : PetPawColors.success)
                            .padding(.horizontal, Spacing.sm)
                            .padding(.vertical, 4)
                            .background(
                                (isConcern ? PetPawColors.warning : PetPawColors.success).opacity(0.14)
                            )
                            .clipShape(Capsule())

                        Text("\(Int(observation.confidence * 100))% confidence")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(PetPawColors.info)
                            .padding(.horizontal, Spacing.sm)
                            .padding(.vertical, 4)
                            .background(PetPawColors.info.opacity(0.14))
                            .clipShape(Capsule())
                    }
                }
                .padding(Spacing.lg)
            }
            .background(Color.white.ignoresSafeArea())
            .navigationTitle("Observation Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    PetHealthHistory(pet: Pet(
        id: "1",
        ownerId: "u",
        name: "Buddy",
        species: "Dog",
        breed: "Golden Retriever",
        dateOfBirth: nil,
        sex: .male,
        weightKg: 24,
        photoURL: nil
    ))
}
