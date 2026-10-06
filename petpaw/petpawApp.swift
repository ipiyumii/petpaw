//
//  petpawApp.swift
//  petpaw
//
//  Created by Piyumi Imalka on 2026-10-04.
//

import SwiftUI
import CoreData
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

@main
struct petpawApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: constants.CoreData.modelName)

        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                print("Core Data loading error: \(error), \(error.userInfo)")
            }
        }

        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

        return container
    }()

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }

        let settings = FirestoreSettings()

        settings.cacheSettings = PersistentCacheSettings(
            sizeBytes: FirestoreCacheSizeUnlimited as NSNumber
        )

        Firestore.firestore().settings = settings
        
        if !UserDefaults.standard.bool(forKey: "appLaunchedBefore") {
            do {
                try Auth.auth().signOut()
                        print("Signed out on first launch")
                    } catch {
                        print("Sign out error: \(error)")
                    }
                    UserDefaults.standard.set(true, forKey: "appLaunchedBefore")
                }

        return true
    }

    // MARK: - Save Core Data
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                print("Core Data save error: \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

extension NSManagedObjectContext {
    static var current: NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
}
