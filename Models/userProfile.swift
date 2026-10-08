//
//  userProfile.swift
//  petpaw
//
//  Created by Piyumi Imalka on 2026-10-08.
//

import Foundation

struct UserProfile: Codable, Equatable {
    let uid: String
    var fullName: String
    var email: String
    var phoneNumber: String
    var bio: String
    let createdAt: Date
}
