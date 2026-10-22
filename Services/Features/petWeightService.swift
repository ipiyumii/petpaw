//
//  petWeightService.swift
//  petpaw
//
//  Created by Piyumi Imalka on 2026-10-22.
//

import CoreData
import Foundation

struct WeightEntry: Identifiable {
    let id: String
    let petId: String
    let weightKg: Double
    let date: Date
}

class WeightService {

    func save(_ entry: WeightEntry) {
        let context = NSManagedObjectContext.current
        let entity = NSEntityDescription.insertNewObject(
            forEntityName: "WeightEntryEntity",
            into: context
        )

        entity.setValue(entry.id, forKey: "id")
        entity.setValue(entry.petId, forKey: "petId")
        entity.setValue(entry.weightKg, forKey: "weightKg")
        entity.setValue(entry.date, forKey: "date")

        do {
            try context.save()
        } catch {
            print("Error saving weight: \(error)")
        }
    }

    func fetchAll(petId: String) -> [WeightEntry] {
        let context = NSManagedObjectContext.current
        let request = NSFetchRequest<NSManagedObject>(
            entityName: "WeightEntryEntity"
        )

        request.predicate = NSPredicate(format: "petId == %@", petId)
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]

        do {
            let results = try context.fetch(request)
            var entries: [WeightEntry] = []

            for item in results {
                if let id = item.value(forKey: "id") as? String,
                   let weight = item.value(forKey: "weightKg") as? Double,
                   let date = item.value(forKey: "date") as? Date {
                    let entry = WeightEntry(
                        id: id,
                        petId: petId,
                        weightKg: weight,
                        date: date
                    )

                    entries.append(entry)
                }
            }

        return entries
        } catch {
            print("Error fetching weights: \(error)")
            return []
        }
    }
}
