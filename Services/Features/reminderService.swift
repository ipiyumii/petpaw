//
//  reminderService.swift
//  petpaw
//
//  Created by Piyumi Imalka on 2026-10-16.
//

import CoreData
import Foundation

struct Reminder: Identifiable {
    let id: String
    let petId: String
    let type: String
    let title: String
    let date: Date
    let repeatOption: String
    let notes: String?
    let isCompleted: Bool
}

final class ReminderService {
    func save(_ reminder: Reminder) {
        let context = NSManagedObjectContext.current
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ReminderEntity")
        fetchRequest.predicate = NSPredicate(format: "id == %@", reminder.id)
        let entity = (try? context.fetch(fetchRequest))?.first
            ?? NSEntityDescription.insertNewObject(forEntityName: "ReminderEntity", into: context)

        entity.setValue(reminder.id, forKey: "id")
        entity.setValue(reminder.petId, forKey: "petId")
        entity.setValue(reminder.type, forKey: "type")
        entity.setValue(reminder.title, forKey: "title")
        entity.setValue(reminder.date, forKey: "date")
        entity.setValue(reminder.repeatOption, forKey: "repeatOption")
        entity.setValue(reminder.notes, forKey: "notes")
        entity.setValue(reminder.isCompleted, forKey: "isCompleted")
        entity.setValue(Date(), forKey: "createdAt")

        try? context.save()
    }

    func fetchAll(petId: String) -> [Reminder] {
        let context = NSManagedObjectContext.current
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ReminderEntity")
        fetchRequest.predicate = NSPredicate(format: "petId == %@", petId)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]

        guard let entities = try? context.fetch(fetchRequest) else { 
            return [] 
        }

        return entities.compactMap { 
            entity in
            guard
                let id = entity.value(forKey: "id") as? String,
                let type = entity.value(forKey: "type") as? String,
                let title = entity.value(forKey: "title") as? String,
                let date = entity.value(forKey: "date") as? Date,
                let repeatOption = entity.value(forKey: "repeatOption") as? String
            else { 
                return nil 
            }

            return Reminder(
                id: id, petId: petId, type: type, title: title, date: date,
                repeatOption: repeatOption,
                notes: entity.value(forKey: "notes") as? String,
                isCompleted: entity.value(forKey: "isCompleted") as? Bool ?? false
            )
        }
    }

    func findPetId(named name: String) -> String? {
        let context = NSManagedObjectContext.current
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "PetEntity")
        fetchRequest.predicate = NSPredicate(format: "name ==[c] %@", name)
        return (try? context.fetch(fetchRequest))?.first?.value(forKey: "id") as? String
    }
}