//
//  utilities.swift
//  petpaw
//
//  Created by Piyumi Imalka on 2026-10-04.
//

import Foundation

struct AppConstants {
    static let appName = "PetPaw"
    static let appVersion = "1.0.0"
    static let appBuild = "1"
    static let minimumOSVersion = "15.0"
    }

    //core data
    struct CoreData {
        static let modelName = "PetPaw"
        static let containerName = "PetPaw"
    }

    //user defualt data
    struct UserDefaults {
        static let isFirstLaunch = "isFirstLaunch"
        static let userID = "userID"
        static let userName = "userName"
        static let userEmail = "userEmail"
        static let lastSyncDate = "lastSeen"
        static let notificationsEnabled = "notificationsEnabled"
    }

    //notification setting
    struct Notifications {
        static let medicationReminderHour = 8
        static let appointmentReminder24Hours = true
        static let appointmentReminder1Hour = true
        static let vaccineDueDays = 30
        static let birthdayReminderEnabled = true
    }

    //validation rules
    struct Validation {
        static let minEmailLength = 5
        static let maxEmailLength = 254
        static let minPasswordLength = 6
        static let maxPasswordLength = 128
        static let minPetNameLength = 2
        static let maxPetNameLength = 50
    }

    //pet type
    struct PetTypes {
        static let dog = "dog"
        static let cat = "cat"
        static let bird = "bird"
        static let rabbit = "rabbit"
        static let other = "other"
    }

    struct Status {
        static let completed = "completed"
        static let upcoming = "upcoming"
        static let overdue = "overdue"
        static let active = "active"
    }

    //error
    struct ErrorMessages {
        static let networkError = "Network connection error. Please try again."
        static let unknownError = "Something went wrong. Please try again."
        static let invalidEmail = "Please enter a valid email address."
        static let weakPassword = "Password must be at least 6 characters."
        static let failedToLoadData = "Failed to load data. Please try again."
        static let failedToSaveData = "Failed to save data. Please try again."
    }

    //feature flags
    struct Features {
        static let healthScanEnabled = true
        static let vetFinderEnabled = true
        static let siriEnabled = true
        static let widgetEnabled = true
        static let offlineModeEnabled = true
        static let darkModeEnabled = true
    }
