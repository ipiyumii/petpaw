//
//  typography.swift
//  petpaw
//
//  Created by Piyumi Imalka on 2026-10-04.
//

import SwiftUI

struct PetPawTypography {
    static let h1 = Font.system(size: 32, weight: .bold, design: .default)
    static let h2 = Font.system(size: 24, weight: .semibold, design: .default)
    static let h3 = Font.system(size: 20, weight: .semibold, design: .default)
    
    static let body = Font.system(size: 16, weight: .regular, design: .default)
    static let bodySmall = Font.system(size: 14, weight: .regular, design: .default)
    static let caption = Font.system(size: 12, weight: .regular, design: .default)

    static let button = Font.system(size: 16, weight: .semibold, design: .default)
    static let badge = Font.system(size: 11, weight: .semibold, design: .default)

    static let code = Font.system(size: 13, weight: .regular, design: .monospaced)
    
}

extension Text {
    func h1Style() -> some View {
         self.font(PetPawTypography.h1)
     }

     func h2Style() -> some View {
         self.font(PetPawTypography.h2)
     }

     func h3Style() -> some View {
         self.font(PetPawTypography.h3)
     }

     func bodyStyle() -> some View {
         self.font(PetPawTypography.body)
     }

     func captionStyle() -> some View {
         self.font(PetPawTypography.caption)
     }
}
