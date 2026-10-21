//
//  healthTimelineUI.swift
//  petpaw
//
//  Created by Piyumi Imalka on 2026-10-18.
//


import SwiftUI

struct HealthTimelineUI: View {
    // @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var petsViewModel: PetsViewModel

    private let timelineService = HealthTimelineService()

    @State private var events: [TimelineEvent] = []
    @State private var searchText = ""
    @State private var selectedCategory: TimelineEvent.Category?
    @State private var showAddCustomEvent = false


    private var filteredEvents: [TimelineEvent] {
        events.filter { event in
            let categoryMatches = selectedCategory == nil ||
                event.category == selectedCategory

            let search = searchText.lowercased()

            let titleMatches = event.title.lowercased().contains(search)
            let subtitleMatches = event.subtitle.lowercased().contains(search)

            return categoryMatches &&
                (searchText.isEmpty || titleMatches || subtitleMatches)
        }
    }


    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            LinearGradient(
                gradient: Gradient(colors: [PetPawColors.primaryBg, Color.white]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView(showsIndicators: false) 
            {
                VStack(spacing: Spacing.md) {
                    petHero
                    titleRow
                        .padding(.horizontal, Spacing.lg)
                    statsRow
                    filterChips
                    timelineList
                }
                .padding(.top, Spacing.md)
            }
            addButton
        }
        .sheet(isPresented: $showAddCustomEvent, onDismiss: loadTimeline) {
            AddReminder(initialType: "custom", isLoggingHealthEvent: true).environmentObject(petsViewModel)
        }
        .onAppear
        {
            loadTimeline()
        }
    }

    private var titleRow: some View {
       HStack{
        Text("Health Timeline")
        .foregroundColor(PetPawColors.textPrimary)
        Spacer()
    }
       .padding(.horizontal, Spacing.lg)

    }

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass").foregroundColor(PetPawColors.textTertiary)
            TextField("Search events", text: $searchText).font(PetPawTypography.body)
        }
        .padding(Spacing.md)
        .background(Color.white)
        .cornerRadius(18)
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(PetPawColors.borderLight, lineWidth: 1))
        .shadow(color: PetPawColors.shadowLight, radius: 10, x: 0, y: 4)
    }

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false){
            HStack(spacing: Spacing.sm) {
                chip(title: "All", color: PetPawColors.primary, selected: selectedCategory == nil) {
                    selectedCategory = nil
                }

                ForEach(TimelineEvent.Category.allCases, id: \.self) { 
                    category in
                    chip(title: category.label,color: category.color,selected: selectedCategory == category) {
                        selectedCategory = category
                    }
                }
            }
            .padding(.horizontal, Spacing.lg)
        }
    }

    private func chip(
        title: String,
        color: Color,
        selected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button {
            action()
        } label: {
            Text(title)
                .font(PetPawTypography.caption)
                .foregroundColor(selected ? .white : color)
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.sm)
                .background(selected ? color : Color.white)
                .overlay(Capsule().stroke(selected ? Color.clear :  color.opacity(0.4), lineWidth: 1))
                .clipShape(Capsule())
        }
    }

private var timelineList: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            if filteredEvents.isEmpty {
                emptyState
            } else {
                ForEach(rows(from: filteredEvents)) { row in
                    switch row {
                        case .month(let title):
                            Text(title.uppercased())
                                .font(.system(size: 12, weight: .heavy))
                                .tracking(0.8)
                                .foregroundColor(PetPawColors.textTertiary)
                                .padding(.top, Spacing.xs)
                        case .event(let event):
                            eventRow(event)
                    }
                }
            }
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.bottom, 110)
    }
    
    private func rows(from events: [TimelineEvent]) -> [TimelineRow] {
        var rows: [TimelineRow] = []
        var lastMonth: String?

        for event in events {
            let month = event.date.formatted(.dateTime.month(.wide).year())
            if month != lastMonth {
                rows.append(.month(month))
                lastMonth = month
            }
            rows.append(.event(event))
        }
        return rows
    }

    private enum TimelineRow: Identifiable {
        case month(String)
        case event(TimelineEvent)

        var id: String {
            switch self {
            case .month(let title): return "month-\(title)"
            case .event(let event): return event.id
            }
        }
    }

    private func eventRow(_ event: TimelineEvent) -> some View {
        HStack(alignment: .top, spacing: Spacing.md) {
            ZStack {
                Circle().fill(event.category.color.opacity(0.12)).frame(width: 42, height: 42)
                Image(systemName: event.category.icon)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(event.category.color)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .top) {
                    Text(event.title)
                        .font(PetPawTypography.body.weight(.semibold))
                        .foregroundColor(PetPawColors.textPrimary)

                    Spacer()

                HStack(spacing: 5) {
                    Circle().fill(event.status.color).frame(width: 6, height: 6)
                    Text(event.status.label.uppercased())
                        .font(.system(size: 10, weight: .bold)).tracking(0.4)
                        .foregroundColor(event.status.color)
                }
            }

                Text(event.subtitle)
                    .font(PetPawTypography.caption)
                    .foregroundColor(PetPawColors.textTertiary)
            }
        }
        .padding(Spacing.md)
        .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(Color.white))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(PetPawColors.borderLight, lineWidth: 1))
        .shadow(color: PetPawColors.shadowLight, radius: 8, x: 0, y: 3)
    }

    private var emptyState: some View {
        VStack(spacing: Spacing.sm) {
            Image(systemName: "clock.badge.questionmark")
                .font(.system(size: 36))
                .foregroundColor(PetPawColors.textTertiary)

            Text(events.isEmpty ? "No health events yet" : "No events match your search")
                .font(PetPawTypography.body)
                .foregroundColor(PetPawColors.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }

    private var addButton: some View {
        Button {
            showAddCustomEvent = true
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(PetPawColors.accentPink)
                .clipShape(Circle())
                .shadow(color: PetPawColors.accentPink.opacity(0.4), radius: 14, x: 0, y: 8)
        }
        .padding(Spacing.lg)
    }

    private func loadTimeline() {
        if let petId = petsViewModel.selectedPet?.id {
            events = timelineService.fetchTimeline(petId: petId)
        }
    }

    private var statsRow: some View {
    HStack(spacing: Spacing.sm) {
        statChip(icon: "calendar", label: "Total", value: "\(events.count)", color: PetPawColors.primary)

        statChip(
            icon: "exclamationmark.circle.fill",
            label: "Overdue",
            value: "\(events.filter { $0.status == .overdue }.count)",
            color: PetPawColors.danger
        )

        statChip(
            icon: "clock.fill",
            label: "Upcoming",
            value: "\(events.filter { $0.status == .upcoming }.count)",
            color: PetPawColors.warning
        )
    }
    .padding(.horizontal, Spacing.lg)
}

    private func statChip(icon: String, label: String, value: String, color: Color) -> some View {
        HStack(spacing: Spacing.xs) {
            ZStack {
                    Circle().fill(color).frame(width: 26, height: 26)
                    Image(systemName: icon).font(.system(size: 12, weight: .semibold)).foregroundColor(.white)
                }

            VStack(alignment: .leading, spacing: 1) {
                Text(value).font(.system(size: 17, weight: .bold)).foregroundColor(PetPawColors.textPrimary)
                Text(label.uppercased()).font(.system(size: 9.5, weight: .semibold)).tracking(0.5).foregroundColor(PetPawColors.textTertiary)
            }
        }
        .padding(.horizontal, Spacing.sm)
        .padding(.vertical, Spacing.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Color.white))
        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(PetPawColors.borderLight, lineWidth:1))
    }

    private var petHero: some View {
    ZStack(alignment: .bottomLeading) {
        heroImage
        .frame(height: 190)
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))

        LinearGradient(
            colors: [Color.black.opacity(0.55), Color.black.opacity(0)],
            startPoint: .bottom,
            endPoint: .top
        )
        .frame(height: 100)
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))

        VStack(alignment: .leading, spacing: 2) {
            Text(petsViewModel.selectedPet?.name ?? "Your pet").font(PetPawTypography.h2).foregroundColor(.white)

            if let breed = petsViewModel.selectedPet?.breed, !breed.isEmpty {
                Text(breed).font(PetPawTypography.caption.weight(.semibold)).foregroundColor(.white.opacity(0.85))
            }
        }
        .padding(Spacing.lg)
    }
    .shadow(color: PetPawColors.shadowLight, radius: 10, x: 0, y: 4)
    .padding(.horizontal, Spacing.lg)
    }

    @ViewBuilder
    private var heroImage: some View {
        if let photoURL = petsViewModel.selectedPet?.photoURL,
        let image = UIImage(dataURLString: photoURL) {
            Image(uiImage: image).resizable().scaledToFill()
        } else {
            LinearGradient(
                colors: [PetPawColors.primaryLight, PetPawColors.primary],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .overlay(
                Image(systemName: "pawprint.fill").font(.system(size: 44)).foregroundColor(.white.opacity(0.5))
            )
        }
    }
}

#Preview {
    HealthTimelineUI().environmentObject(PetsViewModel())
}
