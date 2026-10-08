//
//  errorState.swift
//  petpaw
//
//  Created by Piyumi Imalka on 2026-10-08.
//

import SwiftUI

struct ErrorState: View {
    let message: String
    let retryAction: () -> Void

    var body: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 40))
                .foregroundColor(PetPawColors.danger)

            Text(message)
                .font(PetPawTypography.body)
                .foregroundColor(PetPawColors.textSecondary)
                .multilineTextAlignment(.center)

            Button("Try Again") {
                retryAction()
            }
            .font(PetPawTypography.button)
            .foregroundColor(.white)
            .padding(Spacing.Button.padding)
            .background(PetPawColors.primary)
            .cornerRadius(8)
        }
        .padding(Spacing.lg)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    ErrorState(message: "Failed to load data. Please try again.") {
    }
}
