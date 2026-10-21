//
//  addReminder.swift
//  petpaw
//
//  Created by Piyumi Imalka on 2026-10-16.
//


import SwiftUI

private enum ReminderType: String, CaseIterable {
    case meds
    case vaccine
    case vet
    case custom

    var label: String {
        switch self {
        case .meds:
            return "Meds"
        case .vaccine:
            return "Vaccine"
        case .vet:
            return "Vet"
        case .custom:
            return "Custom"
        }
    }

    var icon: String {
        switch self {
        case .meds:
            return "pills.fill"
        case .vaccine:
            return "cross.vial.fill"
        case .vet:
            return "calendar"
        case .custom:
            return "doc.text.fill"
        }
    }
}

struct AddReminder: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var petsViewModel: PetsViewModel

    private let repeatOptions = ["None", "Daily", "Weekly", "Monthly"]
    private let isLoggingHealthEvent: Bool

    @State private var type: ReminderType = .meds
    @State private var title = ""
    @State private var date = Date()
    @State private var time = Date()
    @State private var repeatOption = "None"
    @State private var notes = ""

    init(initialType: String = "meds", isLoggingHealthEvent: Bool = false) {
        _type = State(initialValue: ReminderType(rawValue: initialType) ?? .meds)
        self.isLoggingHealthEvent = isLoggingHealthEvent
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.lg) {

                    typePicker

                    fieldSection(label: "Title") {
                        TextField("e.g. Antibiotics", text: $title)
                            .textFieldStyle(.roundedBorder)
                    }

                    fieldSection(label: "Date") {
                        DatePicker(
                            "",
                            selection: $date,
                            displayedComponents: .date
                        )
                        .labelsHidden()
                        .datePickerStyle(.compact)
                    }

                    fieldSection(label: "Time") {
                        DatePicker(
                            "",
                            selection: $time,
                            displayedComponents: .hourAndMinute
                        )
                        .labelsHidden()
                        .datePickerStyle(.compact)
                    }

                    if !isLoggingHealthEvent {
                        fieldSection(label: "Repeat") {
                            Picker("Repeat", selection: $repeatOption) {
                                ForEach(repeatOptions, id: \.self) { option in
                                    Text(option).tag(option)
                        }
                    }
                        .pickerStyle(.menu)
                    }
                }

                    fieldSection(label: "Notes (optional)") {
                        TextField(
                            "e.g. Give with food",
                            text: $notes,
                            axis: .vertical
                        )
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(3...5)
                    }

                    saveButton
                }
                .padding(Spacing.lg) 
                .frame(maxWidth: 700)
            }
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [PetPawColors.primaryBg, Color.white]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
            .navigationTitle(isLoggingHealthEvent ? "Log health event" : "New Reminder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                    }
                }
            }
        }
    }

    private var typePicker: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Type")
                .font(PetPawTypography.caption)
                .foregroundColor(PetPawColors.textPrimary)

            HStack(spacing: Spacing.sm) {
                ForEach(ReminderType.allCases, id: \.self) { option in
                    Button {
                        type = option
                    } label: {
                        VStack(spacing: Spacing.xs) {
                            Image(systemName: option.icon)
                                .font(.system(size: 18, weight: .semibold))

                            Text(option.label)
                                .font(PetPawTypography.caption.weight(.semibold))
                        }
                        .foregroundColor(
                            type == option
                            ? PetPawColors.primary
                            : PetPawColors.textSecondary
                        )
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Spacing.sm)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(
                                    type == option
                                    ? PetPawColors.primaryBg
                                    : Color.white
                                )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(
                                    type == option
                                    ? PetPawColors.primary
                                    : Color.clear,
                                    lineWidth: 1.5
                                )
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func fieldSection<Content: View>(
        label: String,
        @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(label)
                .font(PetPawTypography.caption)
                .foregroundColor(PetPawColors.textPrimary)

            content()
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var saveButton: some View 
    {
        Button {
            save()
        } label: {
            Text(isLoggingHealthEvent ? "Save event": "Save Reminder")
                .font(PetPawTypography.button)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(PetPawColors.primary)
                .cornerRadius(16)
        }
        .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        .padding(.top, Spacing.sm)
    }

    private func save() {
        guard let pet = petsViewModel.selectedPet else {
            return
        }
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: time)
        let minute = calendar.component(.minute, from: time)

        guard let reminderDate = calendar.date(
            bySettingHour: hour,
            minute: minute,
            second: 0,
            of: date
        ) else {
            return
        }

        let reminder = Reminder(
            id: UUID().uuidString,
            petId: pet.id,
            type: type.rawValue,
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            date: reminderDate,
            repeatOption: repeatOption,
            notes: notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                ? nil
                : notes.trimmingCharacters(in: .whitespacesAndNewlines),
            isCompleted: false
        )

        ReminderService().save(reminder)
        dismiss()
    }
}

#Preview {
    AddReminder()
        .environmentObject(PetsViewModel())
}