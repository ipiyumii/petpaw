//
//  reminder.swift
//  petpaw
//
//  Created by Piyumi Imalka on 2026-10-16.
//


import SwiftUI

struct Reminder: View {
    @State private var logs: [String] = []

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [PetPawColors.primaryBg, Color.white]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(alignment: .leading, spacing: Spacing.md) {
                Text("Reminders")
                    .font(PetPawTypography.h1)
                    .foregroundColor(PetPawColors.textPrimary)
                    .padding(.horizontal, Spacing.lg)
                    .padding(.top, Spacing.sm)

                Text("Try saying \"Hey Siri, log medicine for [pet name] in PetPaw\"")
                    .font(PetPawTypography.caption)
                    .foregroundColor(PetPawColors.textSecondary)
                    .padding(.horizontal, Spacing.lg)

                if logs.isEmpty {
                    Spacer()

                    Text("No medicine logged yet")
                        .font(PetPawTypography.body)
                        .foregroundColor(PetPawColors.textTertiary)
                        .frame(maxWidth: .infinity)

                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: Spacing.sm) {
                            ForEach(logs, id: \.self) { log in
                                HStack {
                                    Image(systemName: "pills.fill")
                                        .foregroundColor(PetPawColors.warning)

                                    Text(log)
                                        .font(PetPawTypography.bodySmall)
                                        .foregroundColor(PetPawColors.textPrimary)

                                    Spacer()
                                }
                                .padding(Spacing.md)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.white)
                                )
                                .shadow(
                                    color: PetPawColors.shadowLight,
                                    radius: 4,
                                    x: 0,
                                    y: 2
                                )
                            }
                        }
                        .padding(.horizontal, Spacing.lg)
                    }
                }
            }
        }
        .onAppear {
            logs = MedicationLogStore.fetchAll()
        }
    }
}

#Preview {
    Reminder()
}
