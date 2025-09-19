//
//  LocationManager.swift
//  AtlasIQ Mobile
//
//  Created by EWA Kalyna Vision on 9/19/25.
//

import Foundation
import CoreLocation
import MapKit
import SwiftUI

// MARK: - Location Manager
class LocationManager: NSObject, ObservableObject {
    
    // MARK: - Properties
    private let locationManager = CLLocationManager()
    
    @Published var location: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var isLocationEnabled: Bool = false
    @Published var errorMessage: String?
    
    // Location search parameters
    @Published var searchRadius: Double = 16093.4 // 10 miles in meters
    @Published var currentCity: String = ""
    @Published var currentState: String = ""
    @Published var currentCountry: String = ""
    
    // MARK: - Initialization
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 100 // Update every 100 meters
    }
    
    // MARK: - Public Methods
    
    /// Request location permission
    func requestLocationPermission() {
        print("requestLocationPermission() called, current status: \(authorizationStatus.rawValue)")
        switch authorizationStatus {
        case .notDetermined:
            print("Requesting when-in-use authorization")
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            print("Location access denied or restricted")
            // Show alert to user about enabling location in settings
            errorMessage = "Location access is required for local sentiment analysis. Please enable location access in Settings."
        case .authorizedWhenInUse, .authorizedAlways:
            print("Location already authorized")
            startLocationUpdates()
        @unknown default:
            break
        }
    }
    
    /// Start location updates
    func startLocationUpdates() {
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else {
            return
        }
        
        locationManager.startUpdatingLocation()
        isLocationEnabled = true
    }
    
    /// Stop location updates
    func stopLocationUpdates() {
        locationManager.stopUpdatingLocation()
        isLocationEnabled = false
    }
    
    /// Get current location with completion handler
    func getCurrentLocation(completion: @escaping (Result<CLLocation, Error>) -> Void) {
        // If we already have a location, return it immediately
        if let location = location {
            completion(.success(location))
            return
        }
        
        // If location services are not enabled, return error
        guard isLocationEnabled else {
            completion(.failure(LocationError.locationServicesDisabled))
            return
        }
        
        // Start location updates if not already running
        if !isLocationEnabled {
            startLocationUpdates()
        }
        
        // Set up a timeout
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            if self.location == nil {
                completion(.failure(LocationError.locationNotAvailable))
            }
        }
        
        // The location will be updated via the delegate method
        // We'll store the completion handler to call it when location is available
        self.locationCompletion = completion
    }
    
    // Store completion handler for location requests
    private var locationCompletion: ((Result<CLLocation, Error>) -> Void)?
    
    /// Search for places near current location
    func searchNearbyPlaces(query: String, completion: @escaping (Result<[CLLocation], Error>) -> Void) {
        guard let currentLocation = location else {
            completion(.failure(LocationError.locationNotAvailable))
            return
        }
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.region = MKCoordinateRegion(
            center: currentLocation.coordinate,
            latitudinalMeters: searchRadius,
            longitudinalMeters: searchRadius
        )
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let response = response else {
                completion(.failure(LocationError.searchFailed))
                return
            }
            
            let locations = response.mapItems.compactMap { item in
                item.placemark.location
            }
            
            completion(.success(locations))
        }
    }
    
    /// Get location-based hashtags for social media search
    func getLocationHashtags() -> [String] {
        var hashtags: [String] = []
        
        // Add city hashtags
        if !currentCity.isEmpty {
            let cityHashtag = "#\(currentCity.replacingOccurrences(of: " ", with: ""))"
            hashtags.append(cityHashtag)
        }
        
        // Add state hashtags
        if !currentState.isEmpty {
            let stateHashtag = "#\(currentState.replacingOccurrences(of: " ", with: ""))"
            hashtags.append(stateHashtag)
        }
        
        // Add common location hashtags
        hashtags.append("#local")
        hashtags.append("#community")
        hashtags.append("#neighborhood")
        
        return hashtags
    }
    
    /// Get location description for display
    func getLocationDescription() -> String {
        var description = ""
        
        if !currentCity.isEmpty {
            description += currentCity
        }
        
        if !currentState.isEmpty {
            if !description.isEmpty {
                description += ", "
            }
            description += currentState
        }
        
        if !currentCountry.isEmpty {
            if !description.isEmpty {
                description += ", "
            }
            description += currentCountry
        }
        
        return description.isEmpty ? "Location not available" : description
    }
    
    /// Update search radius
    func updateSearchRadius(_ radius: Double) {
        searchRadius = radius
    }
    
    // MARK: - Private Methods
    
    private func reverseGeocodeLocation(_ location: CLLocation) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let self = self else { return }
            
            if let error = error {
                self.errorMessage = "Failed to get location details: \(error.localizedDescription)"
                return
            }
            
            guard let placemark = placemarks?.first else {
                self.errorMessage = "No location details available"
                return
            }
            
            DispatchQueue.main.async {
                self.currentCity = placemark.locality ?? ""
                self.currentState = placemark.administrativeArea ?? ""
                self.currentCountry = placemark.country ?? ""
            }
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        DispatchQueue.main.async {
            self.location = location
            self.reverseGeocodeLocation(location)
            
            // Call completion handler if we have one waiting
            if let completion = self.locationCompletion {
                completion(.success(location))
                self.locationCompletion = nil
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.errorMessage = "Location update failed: \(error.localizedDescription)"
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("LocationManager: Authorization status changed to: \(status.rawValue)")
        DispatchQueue.main.async {
            self.authorizationStatus = status
            
            switch status {
            case .authorizedWhenInUse, .authorizedAlways:
                print("LocationManager: Starting location updates")
                self.startLocationUpdates()
            case .denied, .restricted:
                print("LocationManager: Location access denied")
                self.stopLocationUpdates()
                self.errorMessage = "Location access denied. Please enable location access in Settings."
            case .notDetermined:
                print("LocationManager: Location status not determined")
                self.stopLocationUpdates()
            @unknown default:
                break
            }
        }
    }
}

// MARK: - Location Errors
enum LocationError: Error, LocalizedError {
    case locationNotAvailable
    case searchFailed
    case permissionDenied
    case locationServicesDisabled
    
    var errorDescription: String? {
        switch self {
        case .locationNotAvailable:
            return "Current location is not available"
        case .searchFailed:
            return "Location search failed"
        case .permissionDenied:
            return "Location permission denied"
        case .locationServicesDisabled:
            return "Location services are disabled"
        }
    }
}

// MARK: - Location Permission View
struct LocationPermissionView: View {
    @ObservedObject var locationManager: LocationManager
    let onPermissionGranted: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "location.circle")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("Location Access Required")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("AtlasIQ needs access to your location to analyze local sentiment from social media posts in your area.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            Button("Enable Location Access") {
                print("Enable Location Access button tapped")
                locationManager.requestLocationPermission()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            
            if let errorMessage = locationManager.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .font(.caption)
            }
        }
        .padding()
        .onChange(of: locationManager.authorizationStatus) { status in
            print("LocationPermissionView: Authorization status changed to: \(status.rawValue)")
            if status == .authorizedWhenInUse || status == .authorizedAlways {
                print("LocationPermissionView: Permission granted, calling completion")
                // Small delay to ensure location is updated
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    onPermissionGranted()
                }
            }
        }
    }
}

// MARK: - Location Status View
struct LocationStatusView: View {
    @ObservedObject var locationManager: LocationManager
    
    var body: some View {
        HStack {
            Image(systemName: locationManager.isLocationEnabled ? "location.fill" : "location.slash")
                .foregroundColor(locationManager.isLocationEnabled ? .green : .red)
            
            VStack(alignment: .leading) {
                Text(locationManager.getLocationDescription())
                    .font(.caption)
                    .fontWeight(.medium)
                
                Text("Search Radius: \(Int(locationManager.searchRadius / 1609.34)) miles")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if locationManager.isLocationEnabled {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}
