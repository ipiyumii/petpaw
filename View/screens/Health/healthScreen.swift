//
//  healthScreen.swift
//  petpaw
//
//  Created by Piyumi Imalka on 2026-10-14.
//

import Foundation
import SwiftUI

enum HealthSegment: CaseIterable {
    case overview, scan, records

    var title: String {
        switch self {
            case .overview:
                return "Overview"
            case .scan:
                return "Scan"
            case .records:
                return "Records"
        }
    }
}

struct HealthScreen: View {
    @Binding var segment: HealthSegment
    var onSelectTab: (AppTab) -> Void = { _ in }

    @State private var showFindVetUI = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [PetPawColors.primaryBg, Color.white],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) 
            {
                header
                segmentedControl

            if segment == .records {
                content
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView(showsIndicators: false) {
                    content
                    .padding(.horizontal, Spacing.lg)
                    .padding(.top, Spacing.md)
                    .padding(.bottom, Spacing.xl)
                    .frame(maxWidth: 700)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
        .sheet(isPresented: $showFindVetUI) {
            findVetUI()
        }
    }

    var header: some View {
        HStack {
            Text("Health")
                .font(PetPawTypography.h1)
                .foregroundColor(PetPawColors.textPrimary)

            Spacer()

            Button {
                showFindVetUI = true
            } label: {
                Image(systemName: "mappin.and.ellipse")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(PetPawColors.primary)
                    .frame(width: 40, height: 40)
                    .background(PetPawColors.primary.opacity(0.12))
                    .clipShape(Circle())
            }
            .accessibilityLabel("Find nearby vets")
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.top, Spacing.sm)
    }

    var segmentedControl: some View {
        HStack(spacing: Spacing.xs) {
            ForEach(HealthSegment.allCases, id: \.self) { item in
                Button 
                {
                    segment = item
                } label: {
                    Text(item.title)
                        .font(PetPawTypography.bodySmall.weight(.semibold))
                        .foregroundColor(
                            segment == item ? .white : PetPawColors.textSecondary
                        )
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Spacing.sm)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(
                                    segment == item
                                    ? PetPawColors.primary
                                    : Color.clear
                                )
                    )
                }
            }
        }
        .padding(4)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.white))
        .shadow(color: PetPawColors.shadowLight, radius: 6, x: 0, y: 2)
        .padding(.horizontal, Spacing.lg)
        .padding(.top, Spacing.sm)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: segment)
    }

    @ViewBuilder
    var content: some View {
        switch segment {
            case .overview:
                HealthOverviewSection(
                    onStartScan: 
                    {
                        segment = .scan
                    },
                    onEditWeight: 
                    {
                        onSelectTab(.pets)
                    },
                    onViewRecords: 
                    { 
                        segment = .records 
                    }       
                )

            case .scan: HealthScanTab()

            case .records: HealthRecordsSection()
        }
    }
}

struct HealthOverviewSection: View {
    @EnvironmentObject var petsViewModel: PetsViewModel

    var onStartScan: () -> Void
    var onEditWeight: () -> Void
    var onViewRecords: () -> Void
    private let observationService = HealthObservationService()
    @State private var latestObservation: HealthObservation?
    
    var body: some View {
        VStack(spacing: Spacing.md)
        {
            overallHealthCard
            recentObservationCard
            weightCard
            recordsSummary
        }
        .task {
            if let petId = petsViewModel.selectedPet?.id {
                latestObservation = observationService.fetchObservations(petId: petId).first
            }
        }
    }

    var overallHealthCard: some View {
        Button {
            onStartScan()
        } label: {
            HStack(spacing: Spacing.md) {
                Circle()
                    .fill(PetPawColors.primary.opacity(0.12))
                    .frame(width: 44, height: 44)
                    .overlay 
                    {
                        Image(systemName: "heart.fill").foregroundColor(PetPawColors.primary)
                    }

                VStack(alignment: .leading, spacing: 2){
                    Text("Overall health")
                        .font(PetPawTypography.caption)
                        .foregroundColor(PetPawColors.textSecondary)

                    Text("No concerns logged yet")
                        .font(PetPawTypography.h3)
                        .foregroundColor(PetPawColors.textPrimary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(PetPawColors.textTertiary.opacity(0.5))
            }
            .padding(Spacing.md)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: PetPawColors.shadowLight, radius: 8, x: 0, y: 4)
        }

        .buttonStyle(.plain)
    }

    var recentObservationCard: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Recent observation")
                .font(PetPawTypography.h3)
                .foregroundColor(PetPawColors.textPrimary)

            Button {
                onStartScan()
            } label: {
                if let observation = latestObservation {
                    let isConcern = observation.condition.lowercased().contains("concern")
                    
                    HStack(spacing: Spacing.md) {
                        ZStack {
                            Circle()
                                .fill(
                                    (isConcern ? PetPawColors.warning : PetPawColors.success)
                                        .opacity(0.12)
                                )
                                .frame(width: 44, height: 44)
                            
                            Image(systemName: isConcern ? "exclamationmark.triangle.fill" : "checkmark.circle.fill")
                                .foregroundColor(isConcern ? PetPawColors.warning : PetPawColors.success)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(observation.area) check · \(isConcern ? "Mild concern" : "Normal")")
                                .font(PetPawTypography.body.weight(.semibold))
                                .foregroundColor(PetPawColors.textPrimary)
                            
                            Text(observation.createdAt.formatted(date: .abbreviated, time: .omitted))
                                .font(PetPawTypography.caption)
                                .foregroundColor(PetPawColors.textTertiary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(PetPawColors.textTertiary.opacity(0.5))
                    }
                    .padding(Spacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(Color.white)
                    )
                    .shadow(color: PetPawColors.shadowLight, radius: 8, x: 0, y: 4)
                } else {
                    HStack(spacing: Spacing.md) {
                        ZStack {
                    Circle()
                        .fill(PetPawColors.attention.opacity(0.12))
                        .frame(width: 44, height: 44)
                            Image(systemName: "sparkle.magnifyingglass")
                                .foregroundColor(PetPawColors.attention)
                        }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("No observations yet")
                            .font(PetPawTypography.body.weight(.semibold))
                            .foregroundColor(PetPawColors.textPrimary)

                        Text("Health scans you save will show up here")
                            .font(PetPawTypography.caption)
                            .foregroundColor(PetPawColors.textTertiary)
                    }

                    Spacer()

                    Text("Scan now")
                        .font(PetPawTypography.caption.weight(.semibold))
                        .foregroundColor(PetPawColors.primary)
                }
                .padding(Spacing.md)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color.white)
                )
                .shadow(color: PetPawColors.shadowLight, radius: 8, x: 0, y: 4)
            }
        }
            .buttonStyle(.plain)
        }
    }

    var weightCard: some View {
        Button {
            onEditWeight()
        } label:{
            HStack(spacing: Spacing.md) {
                Circle()
                    .fill(PetPawColors.success.opacity(0.12))
                    .frame(width: 44, height: 44)
                    .overlay {
                        Image(systemName: "scalemass.fill").foregroundColor(PetPawColors.success)
                    }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Weight")
                        .font(PetPawTypography.caption)
                        .foregroundColor(PetPawColors.textSecondary)

                    if let pet = petsViewModel.selectedPet,
                       pet.weightKg > 0 
                       {
                        Text(String(format: "%.1f kg", pet.weightKg))
                            .font(PetPawTypography.h3)
                            .foregroundColor(PetPawColors.textPrimary)
                    } else {
                        Text("Not set")
                            .font(PetPawTypography.h3)
                            .foregroundColor(PetPawColors.textTertiary)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(PetPawColors.textTertiary.opacity(0.5))
            }
            .padding(Spacing.md)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: PetPawColors.shadowLight, radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }

    var recordsSummary: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Records")
                .font(PetPawTypography.h3)
                .foregroundColor(PetPawColors.textPrimary)


            Button(action: onViewRecords) {
                HStack {
                    Image(systemName: "clock.arrow.circlepath")
                        .foregroundColor(PetPawColors.info)
                        .frame(width: 44, height: 44)
                        .background(PetPawColors.info.opacity(0.12))
                        .clipShape(Circle())

                    VStack(alignment: .leading) {
                        Text("Vaccinations & Medications")
                            .font(PetPawTypography.body.weight(.semibold))
                            .foregroundColor(PetPawColors.textPrimary)

                        Text("View the full Health Timeline")
                            .font(PetPawTypography.caption)
                            .foregroundColor(PetPawColors.textTertiary)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .foregroundColor(PetPawColors.textTertiary.opacity(0.5))
                }
                .padding(Spacing.md)
                .background(Color.white)
                .cornerRadius(20)
                .shadow(color: PetPawColors.shadowLight, radius: 8, x: 0, y: 4)
            }
            .buttonStyle(.plain)

        }
    }
}

struct HealthRecordsSection: View {
    var body: some View {
        HealthTimelineUI()
    }
}

struct ComingSoonRow: View {
    var icon: String
    var iconColor: Color
    var title: String
    var subtitle: String? = nil

    var body: some View {
        HStack(spacing: Spacing.md)
        {
            Circle()
                .fill(iconColor.opacity(0.12))
                .frame(width: 44, height: 44)
                .overlay{
                    Image(systemName: icon).foregroundColor(iconColor)
                }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(PetPawTypography.body.weight(.semibold))
                    .foregroundColor(PetPawColors.textPrimary)

                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(PetPawTypography.caption)
                        .foregroundColor(PetPawColors.textTertiary)
                }
            }

            Spacer()

            Text("Coming soon")
                .font(PetPawTypography.caption)
                .foregroundColor(PetPawColors.textTertiary)
        }
        .padding(Spacing.md)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: PetPawColors.shadowLight, radius: 8, x: 0, y: 4)
    }
}

#Preview {
    HealthScreen(segment: .constant(.overview)).environmentObject(PetsViewModel())
}

