//
//  siriKitMedicine.swift
//  petpaw
//
//  Created by Piyumi Imalka on 2026-10-16.
//

import AppIntents
import Foundation

struct MedicationLogStore {
    
    static func add(petName: String) {
        var logs = fetchAll()
        
        let log = "\(petName) — \(Date().formatted(date: .abbreviated, time: .shortened))"
        logs.insert(log, at: 0)
        
        UserDefaults.standard.set(logs, forKey: "medicationLogs")
    }
    
    static func fetchAll() -> [String] {
        return UserDefaults.standard.stringArray(forKey: "medicationLogs") ?? []
    }
}

struct LogMedicationIntent: AppIntent {
    static var title: LocalizedStringResource = "Log Medicine"
    static var description = IntentDescription("Logs when a pet's medicine is given.")
    @Parameter(title: "Pet name")
    var petName: String
    
    func perform() async throws -> some IntentResult & ProvidesDialog {
        MedicationLogStore.add(petName: petName)
        
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
