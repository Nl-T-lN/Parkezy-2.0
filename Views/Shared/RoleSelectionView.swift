//
//  RoleSelectionView.swift
//  ParkEzy
//
//  Landing page for role selection (Driver vs Host mode)
//

import SwiftUI

struct RoleSelectionView: View {
    // MARK: - State
    
    @State private var selectedRole: UserRole = .driver
    @State private var navigateToRole = false
    @State private var showOnboarding = false
    
    // MARK: - Environment
    
    @EnvironmentObject var mapViewModel: MapViewModel
    @EnvironmentObject var bookingViewModel: BookingViewModel
    @EnvironmentObject var hostViewModel: HostViewModel
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background Gradient
                LinearGradient(
                    colors: [
                        DesignSystem.Colors.primary,
                        DesignSystem.Colors.primary.opacity(0.7)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: DesignSystem.Spacing.xl) {
                    // MARK: - Header
                    
                    VStack(spacing: DesignSystem.Spacing.s) {
                        Image(systemName: "parkingsign.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                        
                        Text("ParkEzy")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text("Your Smart Parking Solution")
                            .font(.title3)
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .padding(.top, DesignSystem.Spacing.xxl)
                    
                    Spacer()
                    
                    // MARK: - Role Cards
                    
                    VStack(spacing: DesignSystem.Spacing.l) {
                        // Driver Card
                        RoleCard(
                            role: .driver,
                            icon: "car.fill",
                            title: "Driver Mode",
                            subtitle: "Find & book parking spots",
                            isSelected: selectedRole == .driver
                        ) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedRole = .driver
                            }
                        }
                        
                        // Host Card
                        RoleCard(
                            role: .host,
                            icon: "building.2.fill",
                            title: "Host Mode",
                            subtitle: "Manage your parking spaces",
                            isSelected: selectedRole == .host
                        ) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedRole = .host
                            }
                        }
                    }
                    .padding(.horizontal, DesignSystem.Spacing.l)
                    
                    Spacer()
                    
                    // MARK: - Continue Button
                    
                    Button {
                        withAnimation {
                            navigateToRole = true
                        }
                    } label: {
                        HStack {
                            Text("Continue")
                                .font(.headline)
                            Image(systemName: "arrow.right")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .foregroundColor(DesignSystem.Colors.primary)
                        .cornerRadius(DesignSystem.Spacing.m)
                        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                    }
                    .padding(.horizontal, DesignSystem.Spacing.l)
                    .padding(.bottom, DesignSystem.Spacing.l)
                }
            }
            .navigationDestination(isPresented: $navigateToRole) {
                destinationView
            }
        }
    }
    
    // MARK: - Destination View
    
    @ViewBuilder
    private var destinationView: some View {
        switch selectedRole {
        case .driver:
            HomeMapView()
                .navigationBarBackButtonHidden(false)
        case .host:
            HostDashboardView()
                .navigationBarBackButtonHidden(false)
        }
    }
}

// MARK: - Role Card Component

struct RoleCard: View {
    let role: UserRole
    let icon: String
    let title: String
    let subtitle: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: DesignSystem.Spacing.m) {
                // Icon
                Image(systemName: icon)
                    .font(.system(size: 40))
                    .foregroundColor(isSelected ? DesignSystem.Colors.primary : .gray)
                    .frame(width: 60, height: 60)
                    .background(
                        Circle()
                            .fill(isSelected ? Color.white : Color.white.opacity(0.3))
                    )
                
                // Text
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.title2.bold())
                        .foregroundColor(.white)
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                // Selection Indicator
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                }
            }
            .padding(DesignSystem.Spacing.m)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.Spacing.m)
                    .fill(isSelected ? Color.white.opacity(0.25) : Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.Spacing.m)
                            .stroke(Color.white.opacity(isSelected ? 0.5 : 0.2), lineWidth: 2)
                    )
            )
        }
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

// MARK: - User Role Enum

enum UserRole {
    case driver
    case host
}

// MARK: - Preview

#Preview {
    RoleSelectionView()
        .environmentObject(MapViewModel())
        .environmentObject(BookingViewModel())
        .environmentObject(HostViewModel())
}
