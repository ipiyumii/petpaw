//
//  todoScreen.swift
//  petpaw
//
//  Created by Piyumi Imalka on 2026-10-08.
//

import SwiftUI

struct todoScreen: View {
    let tab: AppTab

    var body: some View{
        ZStack {
            PetPawColors.background.ignoresSafeArea()

            VStack(spacing: Spacing.md){
                ZStack {
                    Circle()
                        .fill(PetPawColors.primary.opacity(0.1))
                        .frame(width: 96, height: 96)

                    Image(systemName: tab.filledIcon)
                        .font(.system(size: 36, weight: .semibold))
                        .foregroundColor(PetPawColors.primary)
                }

                Text(tab.title)
                    .font(PetPawTypography.h2)
                    .foregroundColor(PetPawColors.text)

                Text("coming soon!")
                    .font(PetPawTypography.body)
                    .foregroundColor(PetPawColors.textSecondary)
            }

            .accessibilityElement(children: .combine)
        }
    }
}

#Preview {
    todoScreen(tab: .health)
}
