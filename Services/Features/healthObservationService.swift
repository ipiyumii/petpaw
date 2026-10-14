//
//  healthObservationService.swift
//  petpaw
//
//  Created by Piyumi Imalka on 2026-10-15.
//


import CoreData
import UIKit

struct HealthObservation: Identifiable {
    let id: String
    let petId: String
    let area: String
    let condition: String
    let confidence: Double
    let photo: UIImage?
    let createdAt: Date
}

class HealthObservationService {

    func save(petId: String, area: String, condition: String, confidence: Double, photo: UIImage?) {
        let context = NSManagedObjectContext.current

        let entity = NSEntityDescription.insertNewObject(
            forEntityName: "HealthObservationEntity",
            into: context
        )

        entity.setValue(UUID().uuidString, forKey: "id")
        entity.setValue(petId, forKey: "petId")
        entity.setValue(area, forKey: "area")
        entity.setValue(condition, forKey: "condition")
        entity.setValue(confidence, forKey: "confidence")

        if let imageData = photo?.jpegData(compressionQuality: 0.5) {
            entity.setValue(imageData, forKey: "photoData")
        } else {
            entity.setValue(nil, forKey: "photoData")
        }

        entity.setValue(Date(), forKey: "createdAt")

        do {
            try context.save()
        } catch {
            print("Error saving health observation: \(error)")
        }
    }

    func fetchObservations(petId: String) -> [HealthObservation] {
        let context = NSManagedObjectContext.current

        let request = NSFetchRequest<NSManagedObject>(
            entityName: "HealthObservationEntity"
        )
        request.predicate = NSPredicate(format: "petId == %@", petId)
        request.sortDescriptors = [
            NSSortDescriptor(key: "createdAt", ascending: false)
        ]

        guard let entities = try? context.fetch(request) else {
            return []
        }

        var observations: [HealthObservation] = []

        for entity in entities {
            guard let id = entity.value(forKey: "id") as? String,
                  let area = entity.value(forKey: "area") as? String,
                  let condition = entity.value(forKey: "condition") as? String,
                  let createdAt = entity.value(forKey: "createdAt") as? Date else {
                continue
            }

            let confidence = entity.value(forKey: "confidence") as? Double ?? 0
            let photoData = entity.value(forKey: "photoData") as? Data
            var photo: UIImage? = nil

            if let photoData = photoData {
                photo = UIImage(data: photoData)
            }

            let observation = HealthObservation(
                id: id,
                petId: petId,
                area: area,
                condition: condition,
                confidence: confidence,
                photo: photo,
                createdAt: createdAt
            )

            observations.append(observation)
        }

        return observations
    }
}
