//
//  bioMetricService.swift
//  petpaw
//
//  Created by Piyumi Imalka on 2026-10-08.
//

import Foundation

import LocalAuthentication

final class BioMetricService {
    func authenticate(completion: @escaping (Bool, String?) -> Void) {
        let context = LAContext()
        var error: NSError?

        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
            completion(false, error?.localizedDescription ?? "Biometric authentication not available")
            return
        }

        context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "Unlock PetPaw") { success, evalError in
            DispatchQueue.main.async {
                completion(success, evalError?.localizedDescription)
            }
        }
    }
}
