//
//  tabBarView.swift
//  petpaw
//
//  Created by Piyumi Imalka on 2026-10-08.
//

import SwiftUI

enum AppTab: CaseIterable {
    case home
    case health
    case reminders
    case pets

    var title: String {
        switch self {
        case .home:
            return "Home"
        case .health:
            return "Health"
        case .reminders:
            return "Reminders"
        case .pets:
            return "Pets"
        }
    }

    var icon: String {
        switch self {
        case .home:
            return "house"
        case .health:
            return "heart"
        case .reminders:
            return "bell"
        case .pets:
            return "pawprint"
        }
    }

    var filledIcon: String {
        switch self {
        case .home:
            return "house.fill"
        case .health:
            return "heart.fill"
        case .reminders:
            return "bell.fill"
        case .pets:
            return "pawprint.fill"
        }
    }
}

struct TabBarView: View {
    @Binding var selectedTab: AppTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                Button {
                    selectedTab = tab
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: selectedTab == tab ? tab.filledIcon : tab.icon)
                            .font(.system(size: 22))

                        Text(tab.title)
                            .font(.system(size: 11))
                    }
                    .foregroundColor(
                        selectedTab == tab
                        ? PetPawColors.primary
                        : PetPawColors.textTertiary
                    )
                    .padding(.vertical, Spacing.xs)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.top, Spacing.sm)
        .padding(.bottom, Spacing.xs)
        .background(Color.white)
        .overlay(
            Rectangle()
                .fill(PetPawColors.border)
                .frame(height: 0.5),
            alignment: .top
        )
    }
}

#Preview {
    VStack {
        Spacer()

        TabBarView(selectedTab: .constant(.reminders))
    }
    .background(PetPawColors.background)
}