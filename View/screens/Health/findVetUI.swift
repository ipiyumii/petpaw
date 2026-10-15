//
//  findVetUI.swift
//  petpaw
//
//  Created by Piyumi Imalka on 2026-10-15.
//

import SwiftUI
import MapKit
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()

    @Published var userLocation: CLLocation?
    @Published var authorizationDenied = false

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    func requestLocation() 
    {
        switch manager.authorizationStatus {
            case .notDetermined:
                manager.requestWhenInUseAuthorization()

            case .authorizedWhenInUse, .authorizedAlways:
                manager.requestLocation()

            case .denied, .restricted:
                authorizationDenied = true

            @unknown default:
                break
            }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
            case .authorizedWhenInUse, .authorizedAlways:
                authorizationDenied = false
                manager.requestLocation()

            case .denied, .restricted: authorizationDenied = true

            default:
                break
            }
    }

    func locationManager(_ manager: CLLocationManager,didUpdateLocations locations: [CLLocation])
    {
        if let location = locations.last 
        {
            userLocation = location
        }
    }

    func locationManager(_ manager: CLLocationManager,didFailWithError error: Error) 
    {
        print("Location error: \(error.localizedDescription)")
    }
}

struct VetClinic: Identifiable {
    let id = UUID()
    let name: String
    let address: String
    let phone: String?
    let coordinate: CLLocationCoordinate2D
    let mapItem: MKMapItem
    let distance: Double?
}

struct findVetUI: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var locationManager = LocationManager()

    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 7.2906, longitude: 80.6337),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )

    @State private var clinics: [VetClinic] = []
    @State private var searchText = "veternity clinic"
    @State private var isSearching = false
    @State private var errorMessage: String?
    @State private var favoriteNames: [String] = UserDefaults.standard.stringArray(forKey: "favoriteVetClinics") ?? []

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                searchBar

                Map(coordinateRegion: $region, showsUserLocation: true, annotationItems: clinics) {
                    clinic in MapAnnotation(coordinate: clinic.coordinate)
                    {
                        Image(systemName: "stethoscope.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(PetPawColors.primary)
                    }
                }
                .frame(height: 250)

                if locationManager.authorizationDenied 
                {
                    Text("Location is disabled. You can still search for clinics on the map.")
                        .font(PetPawTypography.bodySmall)
                        .foregroundColor(PetPawColors.textSecondary)
                        .padding()
                }

                if isSearching 
                {
                    ProgressView("Searching for clinics...")
                    .padding()
                }

                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .font(PetPawTypography.bodySmall)
                        .foregroundColor(PetPawColors.textSecondary)
                        .padding()
                }

                if !isSearching && clinics.isEmpty && errorMessage == nil 
                {
                    Text("Search for vet clinics near you.")
                        .font(PetPawTypography.bodySmall)
                        .foregroundColor(PetPawColors.textSecondary)
                        .padding()
                }

                List(clinics) 
                { 
                    clinic in clinicRow(clinic)
                }

                .listStyle(.plain)
            }
            .navigationTitle("Nearby Vets")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading){
                    Button("Close") 
                    {
                        dismiss()
                    }
                }
            }
            .onAppear 
            {
                locationManager.requestLocation()
            }
            .onChange(of: locationManager.userLocation) { 
                location in
                if let location = location 
                {
                    region.center = location.coordinate
                    searchNearbyVets()
                }
            }
        }
    }

    private var searchBar: some View {
        HStack {
            TextField("Search vet clinics", text: $searchText)
                .textFieldStyle(.roundedBorder)
                .padding(.leading)

            Button("Search") {
                searchNearbyVets()
            }
            .disabled(searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .padding(.trailing)
        }
        .padding(.vertical, Spacing.sm)
    }

    private func clinicRow(_ clinic: VetClinic) -> some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 4) {
                Text(clinic.name)
                    .font(PetPawTypography.body.weight(.semibold))

                Text(clinic.address.isEmpty ? "Address unavailable" : clinic.address)
                    .font(PetPawTypography.caption)
                    .foregroundColor(PetPawColors.textSecondary)

                if let phone = clinic.phone, !phone.isEmpty {
                    Text(phone)
                        .font(PetPawTypography.caption)
                        .foregroundColor(PetPawColors.textSecondary)
                }

                if let distance = clinic.distance 
                {
                    Text(String(format: "%.1f km away", distance))
                        .font(PetPawTypography.caption)
                        .foregroundColor(PetPawColors.primary)
                }
            }

            Spacer(minLength: 4)

            Button {
                toggleFavorite(clinic)
            } label: {
                Image(
                    systemName: favoriteNames.contains(clinic.name) ? "star.fill" : "star"
                )
                .foregroundColor(PetPawColors.warning)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(favoriteNames.contains(clinic.name) ? "Remove favorite" : "Add favorite")

            Button {
                openDirections(clinic)
            } label: {
                Image(systemName: "arrow.triangle.turn.up.right.circle.fill").foregroundColor(PetPawColors.primary)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Get directions")
        }
        .padding(.vertical, 4)
    }

    private func searchNearbyVets() {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !query.isEmpty else{
            errorMessage = "Enter a clinic name to search."
            return
        }

        isSearching = true
        errorMessage = nil

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.region = region

        MKLocalSearch(request: request).start { response, error in
            DispatchQueue.main.async {
                isSearching = false

                if let error = error {
                    clinics = []
                    errorMessage = "Could not search for clinics. Please try again."
                    print("Clinic search error: \(error.localizedDescription)")
                    return
                }

                guard let items = response?.mapItems else {
                    clinics = []
                    errorMessage = "No clinics found. Try another search."
                    return
                }

                let userLocation = locationManager.userLocation

                clinics = items.map { 
                    item in
                    let clinicLocation = CLLocation(
                        latitude: item.placemark.coordinate.latitude,
                        longitude: item.placemark.coordinate.longitude
                    )

                    let distance = userLocation.map {
                        $0.distance(from: clinicLocation) / 1000
                    }

                    let addressParts = [item.placemark.thoroughfare,item.placemark.locality]
                    .compactMap { 
                        $0
                    }

                    return VetClinic(
                        name: item.name ?? "Unknown clinic",
                        address: addressParts.joined(separator: ", "),
                        phone: item.phoneNumber,
                        coordinate: item.placemark.coordinate,
                        mapItem: item,
                        distance: distance
                    )
                }

                if clinics.isEmpty {
                    errorMessage = "No clinics in this area."
                }
            }
        }
    }

    private func openDirections(_ clinic: VetClinic) {
        clinic.mapItem.openInMaps(
            launchOptions:[
                MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
            ]
        )
    }

    private func toggleFavorite(_ clinic: VetClinic) {
        if let index = favoriteNames.firstIndex(of: clinic.name) {
            favoriteNames.remove(at: index)
        } else {
            favoriteNames.append(clinic.name)
        }

        UserDefaults.standard.set(favoriteNames, forKey: "favoriteVetClinics")
    }
}

#Preview {
    findVetUI()
}
