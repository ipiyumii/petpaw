//
//  petSwitcherView.swift
//  petpaw
//
//  Created by Piyumi Imalka on 2026-10-13.
//

import SwiftUI

struct PetSwitcherView: View {
    let pets: [Pet]
    let selectedPetId: String?
    let onSelect: (Pet) -> Void
    let onAddPet: () -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.md) {
                ForEach(pets) { pet in
                    PetSwitcherAvatar(
                        pet: pet,
                        isSelected: pet.id == selectedPetId,
                        action: {
                            onSelect(pet)
                        }
                    )
                }

            AddPetAvatar(action: onAddPet)
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.md)
        }
        .fixedSize(horizontal: true, vertical: false)

        .background(
            RoundedRectangle(cornerRadius: 20).fill(Color.white.opacity(0.65))
                .shadow(color: PetPawColors.shadowMedium,radius: 16,x: 0,y: 6)
        )
        .padding(.horizontal, Spacing.md)
    }
    
    private struct PetSwitcherAvatar: View {
        let pet: Pet
        let isSelected: Bool
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                VStack(spacing: Spacing.xs) {
                    avatarImage
                        .frame(width: 56, height: 56)
                        .clipShape(Circle())
                        .overlay(
                            Circle().stroke(isSelected ? PetPawColors.primary : Color.clear, lineWidth: 3)
                        )
                    
                    Text(pet.name.isEmpty ? "Pet" : pet.name)
                        .font(PetPawTypography.caption)
                        .foregroundColor(isSelected ? PetPawColors.primary : PetPawColors.textPrimary)
                        .lineLimit(1)
                        .frame(width: 64)
                }
            }
            .accessibilityLabel(pet.name.isEmpty ? "Unnamed pet" : pet.name)
            .accessibilityHint("Double-tap to switch to this pet's profile")
            .accessibilityAddTraits(isSelected ? [.isSelected] : [])
        }
        
        @ViewBuilder
        private var avatarImage: some View {
            if let photoURLString = pet.photoURL, let image = UIImage(dataURLString: photoURLString) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            }
            else {
                placeholder
            }
        }
        
        private var placeholder: some View {
            ZStack {
                Circle().fill(PetPawColors.primary.opacity(0.12))
                Image(systemName: "pawprint.fill")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(PetPawColors.primary)
            }
        }
    }
    
    private struct AddPetAvatar: View {
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                VStack(spacing: Spacing.xs) {
                    ZStack {
                        Circle().strokeBorder(PetPawColors.primary, style: StrokeStyle(lineWidth: 2, dash: [5]))
                        Image(systemName: "plus")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(PetPawColors.primary)
                    }
                    .frame(width: 56, height: 56)
                    
                    Text("Add Pet")
                        .font(PetPawTypography.caption)
                        .foregroundColor(PetPawColors.primary)
                        .frame(width: 64)
                }
            }
            .accessibilityLabel("Add a new pet")
            .accessibilityHint("Double tap to create a new pet profile")
        }
    }
}
    
    #Preview {
        VStack {
            Spacer()
            PetSwitcherView(
                pets:[
                    Pet(id: "1", ownerId: "u", name: "leo", species: "Dog", breed: "germen shepherd", dateOfBirth: nil, sex: .male, weightKg: 24, photoURL: nil),
                    Pet(id: "2", ownerId: "u", name: "kitty", species: "Cat", breed: nil, dateOfBirth: nil, sex: .male, weightKg: 4, photoURL: nil)
                ],
                selectedPetId: "1",
                onSelect: { _ in },
                onAddPet: {}
            )
            .padding(.bottom, Spacing.xl)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(PetPawColors.primaryBg)
    }