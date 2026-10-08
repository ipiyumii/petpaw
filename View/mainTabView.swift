//
//  mainTabView.swift
//  petpaw
//
//  Created by Piyumi Imalka on 2026-10-07.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: AppTab = .home

    var body: some View {
        VStack(spacing: 0) {
            selectedScreen.frame(maxWidth: .infinity, maxHeight: .infinity)

            TabBarView(selectedTab: $selectedTab)
        }
    }

    @ViewBuilder
    private var selectedScreen: some View {
        switch selectedTab{
            case .home:
                dashboard()
            case .health:
                todoScreen(tab: .health)
            case .reminders:
                todoScreen(tab: .reminders)
            case .pets:
                PetProfile(pet: blankPet)
        }
    }
    
    private var blankPet: Pet {
            Pet(
                id: UUID().uuidString,
                name: "",
                species: "",
                breed: nil,
                dateOfBirth: nil,
                sex: .unknown,
                weightKg: 0,
                photoURL: nil
            )
    }
}

#Preview {
    MainTabView().environmentObject(AuthViewModel())
}
