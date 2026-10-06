//
//  firebaseConfig.swift
//  petpaw
//
//  Created by Piyumi Imalka on 2026-10-06.
//

import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

class FirebaseConfig {
    static let shared = FirebaseConfig()

    private init() {}

    //firebase config
    static func configure() {
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }

        configureFirestore()
    }

    private static func configureFirestore() {
        let settings = FirestoreSettings()

        settings.cacheSettings = PersistentCacheSettings(
            sizeBytes: FirestoreCacheSizeUnlimited as NSNumber
        )

        Firestore.firestore().settings = settings
    }

    static func firestore() -> Firestore {
        Firestore.firestore()
    }

    static func auth() -> Auth {
        Auth.auth()
    }

    static var currentUserID: String? {
        Auth.auth().currentUser?.uid
    }

    static var isAuthenticated: Bool {
        Auth.auth().currentUser != nil
    }
}
