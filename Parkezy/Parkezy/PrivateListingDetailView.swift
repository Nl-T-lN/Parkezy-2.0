//
//  PrivateListingDetailView.swift
//  ParkEzy
//
//  Driver view for private parking listings with slot selection
//

import SwiftUI
import CoreLocation

struct PrivateListingDetailView: View {
    let listing: PrivateParkingListing
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: PrivateParkingViewModel
    
    @State private var selectedSlot: PrivateParkingSlot?
    @State private var showBookingSheet = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // MARK: - Header Image Placeholder
                headerSection
                
                // MARK: - Host Info
                hostInfoSection
                
                // MARK: - Pricing
                pricingSection
                
                // MARK: - Availability
                availabilitySection
                
                // MARK: - Slot Selection
                slotSelectionSection
                
                // MARK: - Amenities
                amenitiesSection
                
                // MARK: - Description
                descriptionSection
            }
        }
        .navigationTitle("Listing Details")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showBookingSheet, onDismiss: { selectedSlot = nil }) {
            if let slot = selectedSlot {
                PrivateBookingSheet(listing: listing, slot: slot)
            }
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        ZStack(alignment: .bottomLeading) {
            // Placeholder gradient for image
            LinearGradient(
                colors: [.blue.opacity(0.6), .purple.opacity(0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 200)
            .overlay(
                Image(systemName: "car.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.white.opacity(0.3))
            )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(listing.title)
                    .font(.title2.bold())
                    .foregroundColor(.white)
                
                HStack {
                    Image(systemName: "mappin")
                    Text(listing.address)
                }
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.9))
            }
            .padding(DesignSystem.Spacing.m)
        }
    }
    
    // MARK: - Host Info
    
    private var hostInfoSection: some View {
        HStack {
            // Avatar
            Circle()
                .fill(LinearGradient(colors: [.orange, .pink], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 50, height: 50)
                .overlay(
                    Text(String(listing.ownerName.prefix(1)))
                        .font(.title2.bold())
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Hosted by")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(listing.ownerName)
                    .font(.headline)
            }
            
            Spacer()
            
            // Rating
            VStack(alignment: .trailing, spacing: 2) {
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text(String(format: "%.1f", listing.rating))
                        .fontWeight(.semibold)
                }
                Text("\(listing.reviewCount) reviews")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(DesignSystem.Spacing.m)
        .background(Color(.systemBackground))
    }
    
    // MARK: - Pricing Section
    
    private var pricingSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.m) {
            Text("Pricing")
                .font(.headline)
            
            HStack(spacing: DesignSystem.Spacing.m) {
                PricingCard(
                    icon: "clock.fill",
                    label: "Hourly",
                    price: "₹\(Int(listing.hourlyRate))",
                    isPopular: true
                )
                
                PricingCard(
                    icon: "sun.max.fill",
                    label: "Daily",
                    price: "₹\(Int(listing.dailyRate))",
                    isPopular: false
                )
                
                PricingCard(
                    icon: "calendar",
                    label: "Monthly",
                    price: "₹\(Int(listing.monthlyRate))",
                    isPopular: false
                )
            }
            
            // Pricing intelligence for comparison
            if let suggested = listing.suggestedHourlyRate {
                HStack {
                    Image(systemName: listing.priceCompetitiveness.icon)
                        .foregroundColor(listing.priceCompetitiveness.color)
                    Text("Area average: ₹\(Int(suggested))/hr")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("•")
                        .foregroundColor(.secondary)
                    Text(listing.priceCompetitiveness.rawValue)
                        .font(.caption.bold())
                        .foregroundColor(listing.priceCompetitiveness.color)
                }
                .padding(.top, 4)
            }
        }
        .padding(DesignSystem.Spacing.m)
        .background(Color(.secondarySystemBackground))
    }
    
    // MARK: - Availability Section
    
    private var availabilitySection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Available Slots")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                HStack(alignment: .bottom, spacing: 4) {
                    Text("\(listing.availableSlots)")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.green)
                    Text("of \(listing.totalSlots)")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 2)
                }
            }
            
            Spacer()
            
            // Booking type indicator
            if listing.autoAcceptBookings {
                Label("Instant Book", systemImage: "bolt.fill")
                    .font(.caption.bold())
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.green)
                    .cornerRadius(20)
            } else {
                Label("Request to Book", systemImage: "hand.raised.fill")
                    .font(.caption.bold())
                    .foregroundColor(.orange)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.orange.opacity(0.15))
                    .cornerRadius(20)
            }
        }
        .padding(DesignSystem.Spacing.m)
    }
    
    // MARK: - Slot Selection
    
    private var slotSelectionSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.m) {
            Text("Select a Slot")
                .font(.headline)
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: DesignSystem.Spacing.s) {
                ForEach(listing.slots) { slot in
                    PrivateSlotCard(
                        slot: slot,
                        isSelected: selectedSlot?.id == slot.id
                    ) {
                        if !slot.isOccupied && !slot.isDisabled {
                            withAnimation(.spring(response: 0.3)) {
                                selectedSlot = slot
                                showBookingSheet = true
                            }
                        }
                    }
                }
            }
        }
        .padding(DesignSystem.Spacing.m)
    }
    
    // MARK: - Amenities
    
    private var amenitiesSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.m) {
            Text("Amenities")
                .font(.headline)
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 140))], spacing: DesignSystem.Spacing.s) {
                if listing.isCovered {
                    AmenityBadge(icon: "umbrella.fill", label: "Covered")
                }
                if listing.hasCCTV {
                    AmenityBadge(icon: "video.fill", label: "CCTV")
                }
                if listing.hasEVCharging {
                    AmenityBadge(icon: "bolt.car.fill", label: "EV Charging")
                }
                if listing.hasSecurityGuard {
                    AmenityBadge(icon: "shield.fill", label: "Security")
                }
                if listing.is24Hours {
                    AmenityBadge(icon: "24.circle.fill", label: "24 Hours")
                }
                if listing.hasWaterAccess {
                    AmenityBadge(icon: "drop.fill", label: "Car Wash")
                }
            }
        }
        .padding(DesignSystem.Spacing.m)
        .background(Color(.secondarySystemBackground))
    }
    
    // MARK: - Description
    
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.s) {
            Text("About this space")
                .font(.headline)
            Text(listing.listingDescription)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(DesignSystem.Spacing.m)
    }
}

// MARK: - Pricing Card

struct PricingCard: View {
    let icon: String
    let label: String
    let price: String
    let isPopular: Bool
    
    var body: some View {
        VStack(spacing: 6) {
            if isPopular {
                Text("POPULAR")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.green)
                    .cornerRadius(4)
            }
            
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(isPopular ? DesignSystem.Colors.primary : .secondary)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(price)
                .font(.headline)
                .foregroundColor(isPopular ? DesignSystem.Colors.primary : .primary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DesignSystem.Spacing.m)
        .background(isPopular ? DesignSystem.Colors.primary.opacity(0.1) : Color(.tertiarySystemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isPopular ? DesignSystem.Colors.primary : Color.clear, lineWidth: 2)
        )
    }
}

// MARK: - Private Slot Card

struct PrivateSlotCard: View {
    let slot: PrivateParkingSlot
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 6) {
                // Icon
                Image(systemName: slot.vehicleSize.icon)
                    .font(.title2)
                    .foregroundColor(slotColor)
                
                // Label
                Text(slot.displayName)
                    .font(.subheadline.bold())
                    .foregroundColor(slot.isDisabled ? .gray : .primary)
                
                // Size badges
                HStack(spacing: 4) {
                    if slot.canFitSUV {
                        Text("SUV")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .background(Color.blue)
                            .cornerRadius(3)
                    }
                }
                
                // Timer for occupied
                if let timeRemaining = slot.formattedTimeRemaining {
                    SlotTimerBadge(timeText: timeRemaining)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(DesignSystem.Spacing.m)
            .background(backgroundColor)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? DesignSystem.Colors.primary : Color.clear, lineWidth: 3)
            )
        }
        .disabled(slot.isOccupied || slot.isDisabled)
    }
    
    private var slotColor: Color {
        if slot.isDisabled { return .gray.opacity(0.5) }
        if slot.isOccupied { return .red.opacity(0.6) }
        return .green
    }
    
    private var backgroundColor: Color {
        if slot.isDisabled { return Color.gray.opacity(0.1) }
        if slot.isOccupied { return Color.red.opacity(0.05) }
        return Color.green.opacity(0.1)
    }
}

// MARK: - Private Booking Sheet

struct PrivateBookingSheet: View {
    let listing: PrivateParkingListing
    let slot: PrivateParkingSlot
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: PrivateParkingViewModel
    
    @State private var durationType: PrivateBookingDuration = .hourly
    @State private var hourlyDuration: Double = 3
    @State private var startDate = Date()
    @State private var endDate = Date().addingTimeInterval(3600 * 24)
    @State private var message = ""
    @State private var isBooking = false
    
    private var rate: Double {
        switch durationType {
        case .hourly: return listing.hourlyRate
        case .daily: return listing.dailyRate
        case .monthly: return listing.monthlyRate
        }
    }
    
    private var totalCost: Double {
        switch durationType {
        case .hourly: return listing.hourlyRate * hourlyDuration * 1.18
        case .daily:
            let days = max(1, Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 1)
            return listing.dailyRate * Double(days) * 1.18
        case .monthly: return listing.monthlyRate * 1.18
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Text("Location")
                        Spacer()
                        Text(listing.title)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    HStack {
                        Text("Slot")
                        Spacer()
                        Text(slot.displayName)
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("Duration Type") {
                    Picker("Type", selection: $durationType) {
                        ForEach(PrivateBookingDuration.allCases, id: \.self) { type in
                            Label(type.rawValue, systemImage: type.icon).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    switch durationType {
                    case .hourly:
                        Stepper(value: $hourlyDuration, in: 1...24, step: 0.5) {
                            Text("\(String(format: "%.1f", hourlyDuration)) hours")
                        }
                        DatePicker("Start", selection: $startDate, in: Date()...)
                    case .daily:
                        DatePicker("From", selection: $startDate, in: Date()..., displayedComponents: .date)
                        DatePicker("To", selection: $endDate, in: startDate..., displayedComponents: .date)
                    case .monthly:
                        DatePicker("Start Month", selection: $startDate, in: Date()..., displayedComponents: .date)
                    }
                }
                
                Section("Message to Host (Optional)") {
                    TextField("Any special requests?", text: $message, axis: .vertical)
                        .lineLimit(3...5)
                }
                
                Section {
                    HStack {
                        Text("Rate")
                        Spacer()
                        Text("₹\(Int(rate))/\(durationType.rawValue.lowercased())")
                    }
                    HStack {
                        Text("Total (incl. GST)")
                            .fontWeight(.bold)
                        Spacer()
                        Text("₹\(Int(totalCost))")
                            .font(.title3.bold())
                            .foregroundColor(DesignSystem.Colors.primary)
                    }
                } header: {
                    Text("Payment")
                }
                
                Section {
                    Button {
                        requestBooking()
                    } label: {
                        HStack {
                            Spacer()
                            if isBooking {
                                ProgressView()
                            } else {
                                Text(listing.autoAcceptBookings ? "Book Now" : "Request Booking")
                                    .fontWeight(.semibold)
                            }
                            Spacer()
                        }
                    }
                    .disabled(isBooking)
                } footer: {
                    if !listing.autoAcceptBookings {
                        Text("This booking requires host approval. You'll be notified once approved.")
                    }
                }
            }
            .navigationTitle("Book Parking")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
    
    private func requestBooking() {
        isBooking = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let endTime: Date
            switch durationType {
            case .hourly:
                endTime = startDate.addingTimeInterval(hourlyDuration * 3600)
            case .daily:
                endTime = endDate
            case .monthly:
                endTime = Calendar.current.date(byAdding: .month, value: 1, to: startDate)!
            }
            
            _ = viewModel.requestBooking(
                listingID: listing.id,
                slotID: slot.id,
                startTime: startDate,
                endTime: endTime,
                durationType: durationType,
                driverMessage: message.isEmpty ? nil : message
            )
            
            isBooking = false
            dismiss()
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        PrivateListingDetailView(
            listing: PrivateParkingListing(
                id: UUID(),
                ownerID: UUID(),
                ownerName: "Test Host",
                title: "Sample Listing",
                address: "123 Test Street",
                coordinates: .init(latitude: 28.5, longitude: 77.2),
                listingDescription: "A nice parking spot",
                slots: [],
                hourlyRate: 40,
                dailyRate: 300,
                monthlyRate: 3000,
                flatFullBookingRate: nil,
                autoAcceptBookings: false,
                instantBookingDiscount: nil,
                hasCCTV: true, isCovered: true, hasEVCharging: true, hasSecurityGuard: true, hasWaterAccess: false, is24Hours: true,
                availableFrom: nil, availableTo: nil, availableDays: [1,2,3,4,5,6,7],
                rating: 4.5, reviewCount: 50,
                imageURLs: [],
                suggestedHourlyRate: 45
            )
        )
        .environmentObject(PrivateParkingViewModel())
    }
}
