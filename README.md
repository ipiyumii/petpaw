# PetPaw

PetPaw is an iOS app for tracking a pet's health — vaccinations, medication reminders, weight, and visible-symptom scans — built with SwiftUI, Firebase (Auth + Firestore), Core Data, WidgetKit, and Siri App Intents.

## Features

- Email/password sign up & login (Firebase Auth), with Face ID app-lock on top
- Pet profiles, weight tracking, vaccination/medication reminders, and a health timeline
- On-device health scan for visible skin/coat symptoms (photos are analysed locally, never uploaded)
- Home Screen & Lock Screen widget showing the next medication reminder
- Siri / Shortcuts support ("Hey Siri, log medicine for Buddy in PetPaw")
- Vet finder (map-based)

## Tech Stack

- SwiftUI, Combine, MVVM
- Firebase Auth + Cloud Firestore (no Firebase Storage — photos are resized, compressed, and stored as base64 data URIs directly in Firestore documents, since Storage requires a paid plan)
- Core Data (local cache, shared with the widget extension via an App Group)
- WidgetKit, AppIntents (Siri Shortcuts)
- Swift Package Manager for dependencies (Firebase iOS SDK) — resolved automatically by Xcode

## Requirements

- Xcode 15.2 or later (iOS 17.2 SDK)
- iOS 17.2+ device or simulator
- A Firebase project (Auth + Firestore enabled) — see [Firebase Setup](#firebase-setup) below
- A physical device if you want to test Siri Shortcuts (the Simulator doesn't support "Hey Siri" voice input) and the widget on a Lock Screen

## Getting Started (Build Steps)

1. Clone the repository.
2. Open `petpaw.xcodeproj` in Xcode.
3. Let Xcode resolve Swift Package dependencies (Firebase) automatically — this happens on first open and may take a minute or two.
4. Add your `GoogleService-Info.plist` to the `petpaw` target (see [Firebase Setup](#firebase-setup) — this file is intentionally **not** committed to this repo).
5. In **Signing & Capabilities**, confirm the **App Groups** capability is enabled on both the `petpaw` app target and the widget extension target, both pointing at the same group ID (`group.com.piyumi.petpaw` by default) — this is required for the widget to read the same local data as the app.
6. Select a Run Destination (an iPhone simulator, or a physical device for Siri/widget testing) and press **⌘R** to build and run.

### Running tests

Unit tests live in `petpawTests/`. Run them from Xcode with **⌘U**

## Firebase Setup

The app talks to Firebase Authentication and Cloud Firestore. **No API keys, tokens, or passwords are committed to this repository** — it's public, so secrets are kept out of git entirely (see `.gitignore`).

To build and run against a backend, you need a `GoogleService-Info.plist` from a Firebase project with **Email/Password Authentication** and **Firestore** enabled, with these top-level collections (see `Constants.Firebase` in `Constants.swift`): `users`, `pets`, `vaccinations`, `medications`, `appointments`, `healthEvents`, `healthScans`.

### Reaching the backend directly

There is no separate custom server — the app talks to Firebase's managed services directly from the client SDK:

- **Auth:** Firebase Authentication (Email/Password provider)
- **Database:** Cloud Firestore, scoped per-user by `uid` (see Firestore Security Rules in the Firebase console for this project)
- **Local-only data:** reminders, pets, and health records are cached in Core Data on-device (shared with the widget via an App Group) and synced to Firestore; there is no separate REST/GraphQL API to call
