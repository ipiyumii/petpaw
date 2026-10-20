//
//  healthTimelineUI.swift
//  petpaw
//
//  Created by Piyumi Imalka on 2026-10-18.
//


import SwiftUI

struct HealthTimelineUI: View {
    @Environment(\.dismiss) private var dismiss
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
            Color(red: 1.0, green: 0.976, blue: 0.941).ignoresSafeArea()

            ScrollView(showsIndicators: false) 
            {
                VStack(spacing: 0) {
                    hero
                    searchBar
                        .padding(.horizontal, Spacing.lg)
                        .offset(y: -24)
                        .padding(.bottom, -24)

                    filterChips
                    timelineList
                }
            }
            addButton
        }
        .sheet(isPresented: $showAddCustomEvent, onDismiss: loadTimeline) {
            AddReminder(initialType: "custom").environmentObject(petsViewModel)
        }
        .onAppear
        {
            loadTimeline()
        }
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                        .frame(width: 36, height: 36)
                        .background(Color.white.opacity(0.18))
                        .clipShape(Circle())
                }

                Spacer()

                Text("Health Timeline")
                    .font(PetPawTypography.h3)
                    .foregroundColor(.white)
                Spacer()
                Text(petsViewModel.selectedPet?.name ?? "Pet")
                    .font(PetPawTypography.caption)
                    .foregroundColor(.white)
            }

            HStack {
                VStack(alignment: .leading) {
                    Text("TOTAL EVENTS")
                    Text("\(events.count)").font(.title2.bold())
                }

                Spacer()

                VStack(alignment: .leading) {
                    Text("OVERDUE")
                    Text("\(events.filter { $0.status == .overdue }.count)")
                        .font(.title2.bold())
                        .foregroundColor(.yellow)
                }

                Spacer()

                VStack(alignment: .leading) {
                    Text("UPCOMING")
                    Text("\(events.filter { $0.status == .upcoming }.count)").font(.title2.bold())
                }
            }
            .font(.caption.bold())
            .foregroundColor(.white)
        }
        .padding(Spacing.lg)
        .padding(.bottom, Spacing.xl)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(PetPawColors.primary)
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass").foregroundColor(PetPawColors.textTertiary)
            TextField("Search events", text: $searchText).font(PetPawTypography.body)
        }
        .padding(Spacing.md)
        .background(Color.white)
        .cornerRadius(18)
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
        .padding(.top, Spacing.md)
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
                .background(selected ? color : color.opacity(0.14))
                .clipShape(Capsule())
        }
    }

    private var timelineList: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            if filteredEvents.isEmpty {
                emptyState
            } else {
                ForEach(filteredEvents) { event in
                    eventRow(event)
                }
            }
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.top, Spacing.md)
        .padding(.bottom, 110)
    }

    private func eventRow(_ event: TimelineEvent) -> some View {
        HStack(alignment: .top, spacing: Spacing.md) {
            Image(systemName: event.category.icon)
                .font(.system(size: 18))
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .background(event.category.color)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: Spacing.xs) {
                HStack {
                    Text(event.title)
                        .font(PetPawTypography.body.weight(.semibold))
                        .foregroundColor(PetPawColors.textPrimary)

                    Spacer()

                    Text(event.status.label)
                        .font(PetPawTypography.caption)
                        .foregroundColor(event.status.color)
                }

                Text(event.subtitle)
                    .font(PetPawTypography.caption)
                    .foregroundColor(PetPawColors.textTertiary)
            }
            .padding(Spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
            .cornerRadius(18)
            .shadow(color: PetPawColors.shadowLight, radius: 6, x: 0, y: 2)
        }
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
}

#Preview {
    HealthTimelineUI().environmentObject(PetsViewModel())
}
