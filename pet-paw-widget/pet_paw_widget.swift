//
//  pet_paw_widget.swift
//  pet-paw-widget
//
//  Created by Piyumi Imalka on 2026-10-20.
//

import WidgetKit
import SwiftUI
import CoreData

enum WidgetCoreDataManager {
    static let container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: constants.CoreData.modelName)

        if let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: constants.CoreData.appGroupId)
        {
            let storeURL = url.appendingPathComponent("\(constants.CoreData.containerName).sqlite")
            container.persistentStoreDescriptions.first?.url = storeURL
        }

        container.loadPersistentStores{ 
            _, error in
            if let error = error 
            {
                print(error.localizedDescription)
            }
        }

        return container
    }()
}

struct ReminderEntry: TimelineEntry {
    let date: Date
    let petName: String
    let reminderTitle: String
    let dueDate: Date?
}

struct ReminderProvider: TimelineProvider {
    func placeholder(in context: Context) -> ReminderEntry 
    {
        ReminderEntry(date: Date(),petName: "Buddy",reminderTitle: "Flea treatment",dueDate: Date().addingTimeInterval(10800))
    }

    func getSnapshot(in context: Context, completion: @escaping (ReminderEntry) -> Void) 
    {
        completion(fetchNextReminder())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ReminderEntry>) -> Void) 
    {
        let entry = fetchNextReminder()
        let nextUpdate = Date().addingTimeInterval(900)
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }

    private func fetchNextReminder() -> ReminderEntry 
    {
        let context = WidgetCoreDataManager.container.viewContext
        let request = NSFetchRequest<NSManagedObject>(entityName: "ReminderEntity")

        request.predicate = NSPredicate(format: "type == %@ AND isCompleted == NO", "meds")
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        request.fetchLimit = 1

        if let reminder = try? context.fetch(request).first,
           let title = reminder.value(forKey: "title") as? String,
           let date = reminder.value(forKey: "date") as? Date,
           let petId = reminder.value(forKey: "petId") as? String 
           {
            let petName = fetchPetName(petId: petId, context: context) ?? "Your pet"

            return ReminderEntry(date: Date(),petName: petName,reminderTitle: title, dueDate: date)
        }

        return ReminderEntry(date: Date(),petName: "",reminderTitle: "", dueDate: nil)
    }

    private func fetchPetName(petId: String, context: NSManagedObjectContext) -> String? {
        let request = NSFetchRequest<NSManagedObject>(entityName: "PetEntity")
        request.predicate = NSPredicate(format: "id == %@", petId)

        let pets = try? context.fetch(request)
        return pets?.first?.value(forKey: "name") as? String
    }
}

struct PetPawWidgetEntryView: View {
    var entry: ReminderEntry

    var body: some View {
        if entry.dueDate == nil {
            VStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)

                Text("No medication due")
                    .font(.caption2)
            }
        } else {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: "pills.fill").foregroundColor(urgencyColor)
                    Text(entry.petName).font(.caption.bold())
                }

                Text(entry.reminderTitle).font(.caption2).lineLimit(1)

                if let date = entry.dueDate {
                    Text(date, style: .relative).font(.caption2.bold()).foregroundColor(urgencyColor)
                }
            }
            .widgetURL(URL(string: "petpaw://reminders"))
        }
    }

    private var urgencyColor: Color {
        guard let date = entry.dueDate else {
            return .gray
        }

        let hoursLeft = date.timeIntervalSinceNow / 3600

        if hoursLeft > 4 {
            return .green
        } else if hoursLeft > 1 {
            return .orange
        } else {
            return .red
        }
    }
}

struct PetPawWidget: Widget {
    let kind = "PetPawWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ReminderProvider()) { 
            entry in PetPawWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Medication Reminder")
        .description("Shows your next medication reminder.")
        .supportedFamilies([.systemSmall, .accessoryRectangular])
    }
}

#Preview(as: .systemSmall) 
{
    PetPawWidget()
} timeline: {
    ReminderEntry(
        date: Date(),
        petName: "Buddy",
        reminderTitle: "Flea treatment",
        dueDate: Date().addingTimeInterval(7200)
    )
}
