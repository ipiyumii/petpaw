//
//  siriKitMedicine.swift
//  petpaw
//
//  Created by Piyumi Imalka on 2026-10-16.
//

import AppIntents
import Foundation

struct LogMedicationIntent: AppIntent {
    static var title: LocalizedStringResource = "Log Medicine"
    static var description = IntentDescription("Logs when a pet's medicine is given.")
    @Parameter(title: "Pet name")
    var petName: String
    
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let service = ReminderService()
        let petId = service.findPetId(named: petName) ?? petName

        service.save(Reminder(
            id: UUID().uuidString,
            petId: petId,
            type: "meds",
            title: "Medicine",
            date: Date(),
            repeatOption: "None",
            notes: "Logged via Siri",
            isCompleted: true
        ))
        
        return .result(dialog: "Logged medicine for \(petName).")
    }
}

struct PetPawShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: LogMedicationIntent(),
            phrases: [
                "Log medicine for \(\.$petName) in \(.applicationName)",
                "Log \(\.$petName)'s medicine in \(.applicationName)"
            ],
            shortTitle: "Log Medicine",
            systemImageName: "pills.fill"
        )
    }
}
