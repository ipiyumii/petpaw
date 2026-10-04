//
//  spacing.swift
//  petpaw
//
//  Created by Piyumi Imalka on 2026-10-04.
//

import SwiftUI

struct Spacing {
    static let xs = CGFloat(4)
    static let sm = CGFloat(8)
    static let md = CGFloat(16)
    static let lg = CGFloat(24)
    static let xl = CGFloat(32)
    static let xxl = CGFloat(48)

    static let screenPadding = xxl
    static let cardPadding = lg
    static let elementSpacing = md
    static let iconTextGap = sm

    static let vStackSpacing = md
    static let hStackSpacing = sm
    static let listItemSpacing = md

    static let allSmall = EdgeInsets(top: md, leading: md, bottom: md, trailing: md)
    static let allMedium = EdgeInsets(top: lg, leading: lg, bottom: lg, trailing: lg)
    static let horizontalMedium = EdgeInsets(top: 0, leading: md, bottom: 0, trailing: md)
    static let horizontalLarge = EdgeInsets(top: 0, leading: lg, bottom: 0, trailing: lg)
    static let verticalMedium = EdgeInsets(top: md, leading: 0, bottom: md, trailing: 0)

    struct Button {
        static let vertical = CGFloat(12)
        static let horizontal = CGFloat(16)
        static let padding = EdgeInsets(top: vertical, leading: horizontal, bottom: vertical, trailing: horizontal)
    }

    struct Input {
        static let vertical = CGFloat(12)
        static let horizontal = CGFloat(16)
        static let padding = EdgeInsets(top: vertical, leading: horizontal, bottom: vertical, trailing: horizontal)
    }

    struct Card {
        static let padding = lg
        static let cornerRadius = CGFloat(12)
        static let spacing = md
    }
}

extension View {
    func standardPadding() -> some View {
        padding(Spacing.md)
    }

    func screenPadding() -> some View {
        padding(Spacing.xxl)
    }

    func cardPadding() -> some View {
        padding(Spacing.lg)
    }

    func horizontalPadding(_ amount: CGFloat = Spacing.md) -> some View {
        padding(.horizontal, amount)
    }

    func verticalPadding(_ amount: CGFloat = Spacing.md) -> some View {
        padding(.vertical, amount)
    }
}
