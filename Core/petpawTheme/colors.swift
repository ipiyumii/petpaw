//
//  colors.swift
//  petpaw
//
//  Created by Piyumi Imalka on 2026-10-04.
//

import SwiftUI

struct PetPawColors {
    //primary colors
    static let primary = Color(red: 0.2, green: 0.6, blue: 1.0)
    static let primaryDark = Color(red: 0.0, green: 0.4, blue: 0.8)
    static let primaryLight = Color(red: 0.6, green: 0.8, blue: 1.0)
    static let success = Color(red: 0.063, green: 0.725, blue: 0.506)
    static let successDark = Color(red: 0.035, green: 0.59, blue: 0.412)
    static let warning = Color(red: 0.961, green: 0.619, blue: 0.059)
    static let warningDark = Color(red: 0.855, green: 0.592, blue: 0.04)
    static let danger = Color(red: 0.937, green: 0.267, blue: 0.267)
    static let dangerDark = Color(red: 0.863, green: 0.149, blue: 0.149)
    static let info = Color(red: 0.545, green: 0.361, blue: 0.965)
    static let attention = Color(red: 0.024, green: 0.714, blue: 0.831)

    //text color
    static let textPrimary = Color(red: 0.122, green: 0.165, blue: 0.204)
    static let textSecondary = Color(red: 0.42, green: 0.458, blue: 0.49)
    static let textTertiary = Color(red: 0.612, green: 0.639, blue: 0.667)
    static let textInverse = Color.white

    //bg colors
    static let bgLight = Color.white
    static let cardLight = Color(red: 0.976, green: 0.978, blue: 0.98)
    static let bgDark = Color(red: 0.067, green: 0.094, blue: 0.157)
    static let cardDark = Color(red: 0.122, green: 0.165, blue: 0.204)

    //border colors
    static let borderLight = Color(red: 0.898, green: 0.906, blue: 0.914)
    static let borderDark = Color(red: 0.216, green: 0.255, blue: 0.314)
    static let borderFocus = primary

    //shadow
    static let shadowLight = Color.black.opacity(0.05)
    static let shadowMedium = Color.black.opacity(0.1)
    static let shadowDark = Color.black.opacity(0.15)

    //light/dark mode
    static var background: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ?
            UIColor(red: 0.067, green: 0.094, blue: 0.157, alpha: 1) :
            UIColor.white
        })
    }

    static var card: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ?
            UIColor(red: 0.122, green: 0.165, blue: 0.204, alpha: 1) :
            UIColor(red: 0.976, green: 0.978, blue: 0.98, alpha: 1)
        })
    }

    static var text: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ?
            UIColor.white :
            UIColor(red: 0.122, green: 0.165, blue: 0.204, alpha: 1)
        })
    }

    static var border: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ?
            UIColor(red: 0.216, green: 0.255, blue: 0.314, alpha: 1) :
            UIColor(red: 0.898, green: 0.906, blue: 0.914, alpha: 1)
        })
    }
}
