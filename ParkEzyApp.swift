//
//  ParkEzyApp.swift
//  ParkEzy
//
//  Created by Staff iOS Engineer
//  iOS 17.0+ SwiftUI App
//

import SwiftUI

@main
struct ParkEzyApp: App {
    // MARK: - State Management
    
    /// Initialize all ViewModels as StateObjects to persist throughout app lifecycle
    @StateObject private var mapViewModel = MapViewModel()
    @StateObject private var bookingViewModel = BookingViewModel()
    @StateObject private var hostViewModel = HostViewModel()
    
    // MARK: - Scene Configuration
    
    var body: some Scene {
        WindowGroup {
            RoleSelectionView()
                .environmentObject(mapViewModel)
                .environmentObject(bookingViewModel)
                .environmentObject(hostViewModel)
                .onAppear {
                    setupNotifications()
                    setupLocationTracking()
                }
        }
    }
    
    // MARK: - App Initialization
    
    /// Request notification permissions on app launch
    private func setupNotifications() {
        NotificationManager.shared.requestAuthorization { granted in
            if granted {
                print("✅ Notification permissions granted")
            } else {
                print("⚠️ Notification permissions denied")
            }
        }
    }
    
    /// Initialize location tracking (required for geofencing)
    private func setupLocationTracking() {
        LocationManager.shared.requestLocationPermission()
        print("📍 Location tracking initialized")
    }
}

// MARK: - App Lifecycle Extension

extension ParkEzyApp {
    /// Called when app enters background
    /// Ensures geofencing continues monitoring
    private func handleAppBackground() {
        // CoreLocation automatically handles background location updates
        // when background modes are enabled in Info.plist
        print("🌙 App entered background - Geofencing active")
    }
    
    /// Called when app returns to foreground
    /// Refresh session state if active booking exists
    private func handleAppForeground() {
        if bookingViewModel.activeSession != nil {
            bookingViewModel.refreshSessionState()
            print("☀️ App returned to foreground - Session refreshed")
        }
    }
}
