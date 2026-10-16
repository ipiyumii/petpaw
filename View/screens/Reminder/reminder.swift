//
//  reminder.swift
//  petpaw
//
//  Created by Piyumi Imalka on 2026-10-16.
//

import SwiftUI

struct ReminderUI: View {
    @EnvironmentObject var petsViewModel: PetsViewModel

    @State private var reminders: [Reminder] = []
    @State private var showAddReminder = false

    private let service = ReminderService()

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [PetPawColors.primaryBg, Color.white]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(alignment: .leading, spacing: Spacing.md) {
                HStack {
                    Text("Reminders")
                        .font(PetPawTypography.h1)
                        .foregroundColor(PetPawColors.textPrimary)

                    Spacer()

                    Button {
                        showAddReminder = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(PetPawColors.primary)
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.top, Spacing.sm)

                Text("Try saying \"Hey Siri, log medicine for [pet name] in PetPaw\"")
                    .font(PetPawTypography.caption)
                    .foregroundColor(PetPawColors.textSecondary)
                    .padding(.horizontal, Spacing.lg)

                if reminders.isEmpty {
                    Spacer()

                    Text("No reminders yet")
                        .font(PetPawTypography.body)
                        .foregroundColor(PetPawColors.textTertiary)
                        .frame(maxWidth: .infinity)

                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: Spacing.sm) {
                            ForEach(reminders) { reminder in
                                reminderRow(reminder)
                            }
                        }
                        .padding(.horizontal, Spacing.lg)
                    }
                }
            }
            .frame(maxWidth: 700)
        }
        .sheet(isPresented: $showAddReminder, onDismiss: {
            loadReminders()
        }) {
            AddReminder()
                .environmentObject(petsViewModel)
        }
        .onAppear {
            loadReminders()
        }
        .onChange(of: petsViewModel.selectedPet?.id) { _ in
            loadReminders()
        }
    }

    private func reminderRow(_ reminder: Reminder) -> some View {
        HStack(spacing: Spacing.md) {
            ZStack {
                Circle()
                    .fill(iconColor(for: reminder.type).opacity(0.12))
                    .frame(width: 44, height: 44)

                Image(systemName: icon(for: reminder.type))
                    .foregroundColor(iconColor(for: reminder.type))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(reminder.title)
                    .font(PetPawTypography.body.weight(.semibold))
                    .foregroundColor(PetPawColors.textPrimary)

                Text(reminder.date.formatted(date: .abbreviated, time: .shortened))
                    .font(PetPawTypography.caption)
                    .foregroundColor(PetPawColors.textTertiary)

                if reminder.repeatOption != "None" {
                    Text("Repeats \(reminder.repeatOption.lowercased())")
                        .font(PetPawTypography.caption)
                        .foregroundColor(PetPawColors.primary)
                }
            }

            Spacer()

            Button {
                toggleCompleted(reminder)
            } label: {
                Image(systemName: reminder.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundColor(
                        reminder.isCompleted ? PetPawColors.success : PetPawColors.textTertiary
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
        )
        .shadow(color: PetPawColors.shadowLight, radius: 4, x: 0, y: 2)
    }

    private func icon(for type: String) -> String {
        if type == "meds" 
        {
            return "pills.fill"
        } else if type == "vaccine" {
            return "cross.vial.fill"
        } else if type == "vet" {
            return "calendar"
        } else {
            return "doc.text.fill"
        }
    }

    private func iconColor(for type: String) -> Color {
        if type == "meds" {
            return PetPawColors.warning
        } else if type == "vaccine" {
            return PetPawColors.info
        } else if type == "vet" {
            return PetPawColors.attention
        } else {
            return PetPawColors.textSecondary
        }
    }

    private func toggleCompleted(_ reminder: Reminder) {
        let updatedReminder = Reminder(
            id: reminder.id,
            petId: reminder.petId,
            type: reminder.type,
            title: reminder.title,
            date: reminder.date,
            repeatOption: reminder.repeatOption,
            notes: reminder.notes,
            isCompleted: !reminder.isCompleted
        )

        service.save(updatedReminder)
        loadReminders()
    }

    private func loadReminders() {
        if let petId = petsViewModel.selectedPet?.id 
        {
            reminders = service.fetchAll(petId: petId)
        } else {
            reminders = []
        }
    }
}

#Preview {
    ReminderUI()
        .environmentObject(PetsViewModel())
}
