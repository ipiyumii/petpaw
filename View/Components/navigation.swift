//
//  navigation.swift
//  petpaw
//
//  Created by Piyumi Imalka on 2026-10-07.
//

import SwiftUI

enum AppTab: CaseIterable {
    case home
    case health
    case reminders
    case profile

    var title: String {
        switch self{
            case .home: return "Home"
            case .health: return "Health"
            case .reminders: return "Reminders"
            case .profile: return "Profile"
        }
    }

    var icon: String {
        switch self{
            case .home: return "house"
            case .health: return "heart"
            case .reminders: return "bell"
            case .profile: return "person"
        }
    }

    var filledIcon: String {
        switch self{
            case .home: return "house.fill"
            case .health: return "heart.fill"
            case .reminders: return "bell.fill"
            case .profile: return "person.fill"
        }
    }
}

struct TabBarView: View {
    @Binding var selectedTab: AppTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                tabButton(for: tab).frame(maxWidth: .infinity)
            }
        }
        .padding(.top, Spacing.sm)
        .padding(.bottom, Spacing.xs)

        .background(Color.white.ignoresSafeArea(edges: .bottom))
        .overlay(Rectangle().fill(PetPawColors.border).frame(height: 0.5),alignment: .top
        )

        .shadow(color: PetPawColors.shadowMedium, radius: 12, x: 0, y: -4)
    }

    private func tabButton(for tab: AppTab) -> some View{
        let isSelected = tab == selectedTab

        return Button {
            selectTab(tab)
        } label:{
            VStack(spacing: 4) {
                Image(systemName: isSelected ? tab.filledIcon : tab.icon)
                    .font(.system(size: 22, weight: .semibold))
                    .scaleEffect(isSelected ? 1.1 : 1.0)

                Text(tab.title)
                    .font(.system(size: 11, weight: isSelected ? .semibold : .medium))
            }
            .foregroundColor(isSelected ? PetPawColors.primary : PetPawColors.textTertiary)
            .padding(.vertical, Spacing.xs)
        }
        .accessibilityLabel(tab.title)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
        .accessibilityHint("Double-tap to switch to the \(tab.title) tab")
    }

    private func selectTab(_ tab: AppTab) {
        guard tab != selectedTab else { return }
        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
            selectedTab = tab
        }
    }
}

#Preview {
    VStack {
        Spacer()
        TabBarView(selectedTab: .constant(.reminders))
    }
    
    .background(PetPawColors.background)
}
