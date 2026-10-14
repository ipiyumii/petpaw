//
//  mainTabView.swift
//  petpaw
//
//  Created by Piyumi Imalka on 2026-10-07.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var AuthViewModel: AuthViewModel
    @State private var selectedTab: AppTab = .home
    @StateObject private var petViewModel = PetsViewModel()
    @State private var showPetSwitcher = false
    @State private var showAddPet = false
    @State private var healthSegment: HealthSegment = .overview

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                selectedScreen.frame(maxWidth: .infinity, maxHeight: .infinity)
                    TabBarView(selectedTab: $selectedTab, onPetTap: togglePetSwitcher)
            }
            if showPetSwitcher {
                Color.black.opacity(0.001).ignoresSafeArea().onTapGesture {
                    togglePetSwitcher()
                    }

                VStack { 
                    Spacer()
                    HStack {
                        Spacer()
                        PetSwitcherView(
                            pets: petViewModel.pets,    
                            selectedPetId: petViewModel.selectedPet?.id,
                            onSelect: selectPet,
                            onAddPet: startAddPet
                        ).fixedSize(horizontal: true, vertical: false)
                    }
                    .padding(.bottom, 84)
                }

                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }

        }
        .environmentObject(petViewModel)
        .sheet(isPresented: $showAddPet) {
            NavigationStack {
               PetProfile(pet: blankPet, isNewPet: true)
            }
            .environmentObject(petViewModel)
        }.task {
            await petViewModel.loadPets(ownerId: AuthViewModel.authService.currentUser?.uid ?? "")
        }
        
    }

    @ViewBuilder
    private var selectedScreen: some View {
        switch selectedTab{
            case .home:
                dashboard(onSelectTab: navigate, onScanHealth: goToScan, onAddRecord: goToRecords)
            case .health:
                HealthScreen(segment: $healthSegment, onSelectTab: navigate)
            case .reminders:
                todoScreen(tab: .reminders)
            case .pets:
            PetProfile(
                pet: petViewModel.selectedPet ?? blankPet,isNewPet: petViewModel.selectedPet == nil)
                .id(petViewModel.selectedPet?.id ?? "blank")
        }
    }

    private func togglePetSwitcher() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            showPetSwitcher.toggle()
        }
    }

    private func selectPet(_ pet: Pet) {
        petViewModel.select(pet)
        selectedTab = .pets
        togglePetSwitcher()
    }

    private func startAddPet() {
        togglePetSwitcher()
        showAddPet = true
    }
    
    private var blankPet: Pet {
            Pet(
                id: UUID().uuidString,
                ownerId: AuthViewModel.authService.currentUser?.uid ?? "",
                name: "",
                species: "",
                breed: nil,
                dateOfBirth: nil,
                sex: .unknown,
                weightKg: 0,
                photoURL: nil
            )
    }
    
    private func navigate(to tab: AppTab) {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
            selectedTab = tab
        }
    }

    private func goToScan() 
    {
        healthSegment = .scan
        navigate(to: .health)
    }

    private func goToRecords() 
    {
        healthSegment = .records
        navigate(to: .health)
    }
}

#Preview {
    MainTabView().environmentObject(AuthViewModel())
}
