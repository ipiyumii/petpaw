//
//  colors.swift
//  petpaw
//
//  Created by Piyumi Imalka on 2026-10-04.
//

import SwiftUI

struct PetPawColors {
    //primary colors
    static let primary = Color(red: 0.18, green: 0.49, blue: 0.357)
    static let primaryLight = Color(red: 0.498, green: 0.765, blue: 0.635)
    static let primaryBg = Color(red: 0.89, green: 0.945, blue: 0.914)
    static let success = primary
    static let successDark = Color(red: 0.12, green: 0.35, blue: 0.25)
    static let warning = Color(red: 0.961, green: 0.619, blue: 0.059)
    static let warningDark = Color(red: 0.855, green: 0.592, blue: 0.04)
    static let danger = Color(red: 0.937, green: 0.267, blue: 0.267)
    static let dangerDark = Color(red: 0.863, green: 0.149, blue: 0.149)
    static let info = Color(red: 0.545, green: 0.361, blue: 0.965)
    static let attention = Color(red: 0.024, green: 0.714, blue: 0.831)
    
    //text color
    static let textPrimary = Color(red: 0.408, green: 0.474, blue: 0.435)
    static let textSecondary = Color(red: 0.42, green: 0.458, blue: 0.49)
    static let textTertiary = Color(red: 0.612, green: 0.639, blue: 0.667)

    //bg colors
    static let backgroundLight = Color.white
    static let cardLight = Color(red: 0.89, green: 0.945, blue: 0.914)
    static let backgroundDark = Color(red: 0.067, green: 0.094, blue: 0.157)
    static let cardDark = Color(red: 0.122, green: 0.165, blue: 0.204)
    
    //border colors
    static let borderLight = Color(red: 0.89, green: 0.945, blue: 0.914)
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
        UIColor(red: 0.89, green: 0.945, blue: 0.914, alpha: 1)  // Light green
        })
    }

    static var text: Color {
        Color(UIColor { traitCollection in
              traitCollection.userInterfaceStyle == .dark ?
              UIColor.white :
              UIColor(red: 0.408, green: 0.474, blue: 0.435, alpha: 1)  // Gray-green
          })
    }

    static var border: Color {
        Color(UIColor { traitCollection in
              traitCollection.userInterfaceStyle == .dark ?
              UIColor(red: 0.216, green: 0.255, blue: 0.314, alpha: 1) :
              UIColor(red: 0.89, green: 0.945, blue: 0.914, alpha: 1)   // Light green
          })
    }
}
