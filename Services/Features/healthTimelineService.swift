//
//  healthTimelineService.swift
//  petpaw
//
//  Created by Piyumi Imalka on 2026-10-18.
//


import SwiftUI

struct TimelineEvent: Identifiable {
    enum Category: String, CaseIterable {
        case vaccine
        case meds
        case vet
        case custom
        case scan

        var label: String {
            if self == .vaccine {
                return "Vaccine"
            } else if self == .meds {
                return "Medication"
            } else if self == .vet {
                return "Vet Visit"
            } else if self == .custom {
                return "Custom"
            } else {
                return "Scan"
            }
        }

        var icon: String {
            if self == .vaccine {
                return "syringe.fill"
            } else if self == .meds {
                return "pills.fill"
            } else if self == .vet {
                return "cross.case.fill"
            } else if self == .custom {
                return "note.text"
            } else {
                return "sparkle.magnifyingglass"
            }
        }

        var color: Color {
            if self == .vaccine {
                return PetPawColors.info
            } else if self == .meds {
                return PetPawColors.warning
            } else if self == .vet {
                return PetPawColors.attention
            } else if self == .custom {
                return PetPawColors.accentPink
            } else {
                return PetPawColors.accentBlue
            }
        }
    }

    enum Status: Equatable {
        case overdue
        case upcoming
        case done
        case logged

        var label: String {
            if self == .overdue {
                return "Overdue"
            } else if self == .upcoming {
                return "Upcoming"
            } else if self == .done {
                return "Done"
            } else {
                return "Logged"
            }
        }

        var color: Color {
            if self == .overdue {
                return PetPawColors.danger
            } else if self == .upcoming {
                return PetPawColors.warningDark
            } else if self == .done {
                return PetPawColors.success
            } else {
                return PetPawColors.info
            }
        }
    }

    let id: String
    let category: Category
    let title: String
    let subtitle: String
    let date: Date
    let status: Status
}

final class HealthTimelineService {
    private let reminderService = ReminderService()
    private let observationService = HealthObservationService()

    func fetchTimeline(petId: String) -> [TimelineEvent] {
        var events: [TimelineEvent] = []
        let reminders = reminderService.fetchAll(petId: petId)

        for reminder in reminders {
            let category = TimelineEvent.Category(rawValue: reminder.type) ?? .custom
            var status: TimelineEvent.Status

            if reminder.isCompleted 
            {
                status = .done
            } else if reminder.date < Date() {
                status = .overdue
            } else {
                status = .upcoming
            }

            let event = TimelineEvent(
                id: reminder.id,
                category: category,
                title: reminder.title,
                subtitle: "\(category.label) · \(reminder.date.formatted(date: .abbreviated, time: .omitted))",
                date: reminder.date,
                status: status
            )

            events.append(event)
        }

        let observations = observationService.fetchObservations(petId: petId)

        for observation in observations {
            var result = "Normal"

            if observation.condition.lowercased().contains("concern") 
            {
                result = "Mild concern"
            }

            let event = TimelineEvent(
                id: observation.id,
                category: .scan,
                title: "\(observation.area) scan · \(result)",
                subtitle: "Scan · \(observation.createdAt.formatted(date: .abbreviated, time: .omitted))",
                date: observation.createdAt,
                status: .logged
            )

            events.append(event)
        }

        events.sort { first, second in
            first.date > second.date
        }

        return events
    }
}
