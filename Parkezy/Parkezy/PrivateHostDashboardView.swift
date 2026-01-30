//
//  PrivateHostDashboardView.swift
//  ParkEzy
//
//  Dashboard for private parking hosts with approval queue and pricing intelligence
//

import SwiftUI

struct PrivateHostDashboardView: View {
    @EnvironmentObject var viewModel: PrivateParkingViewModel
    @State private var selectedListing: PrivateParkingListing?
    @State private var showAddListing = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.l) {
                // MARK: - Stats Cards
                statsSection
                
                // MARK: - Pending Approvals
                if !viewModel.pendingApprovals.isEmpty {
                    pendingApprovalsSection
                }
                
                // MARK: - My Listings
                myListingsSection
                
                // MARK: - Recent Activity
                recentActivitySection
            }
            .padding(DesignSystem.Spacing.m)
        }
        .navigationTitle("My Parking Spaces")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showAddListing = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                }
            }
        }
        .sheet(isPresented: $showAddListing) {
            Text("Add New Listing (Coming Soon)")
                .font(.title)
                .padding()
        }
    }
    
    // MARK: - Stats Section
    
    private var statsSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DesignSystem.Spacing.m) {
                HostStatCard(
                    icon: "car.fill",
                    label: "Active Slots",
                    value: "\(viewModel.myListings.flatMap { $0.slots }.filter { $0.isOccupied }.count)",
                    color: .green
                )
                
                HostStatCard(
                    icon: "hourglass",
                    label: "Pending",
                    value: "\(viewModel.pendingApprovals.count)",
                    color: .orange
                )
                
                HostStatCard(
                    icon: "indianrupeesign.circle.fill",
                    label: "This Month",
                    value: "₹\(Int.random(in: 8000...15000))",
                    color: DesignSystem.Colors.primary
                )
                
                HostStatCard(
                    icon: "star.fill",
                    label: "Avg Rating",
                    value: String(format: "%.1f", viewModel.myListings.map { $0.rating }.reduce(0, +) / Double(max(1, viewModel.myListings.count))),
                    color: .yellow
                )
            }
        }
    }
    
    // MARK: - Pending Approvals
    
    private var pendingApprovalsSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.m) {
            HStack {
                Text("Pending Approvals")
                    .font(.headline)
                
                Text("\(viewModel.pendingApprovals.count)")
                    .font(.caption.bold())
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.orange)
                    .cornerRadius(10)
                
                Spacer()
            }
            
            ForEach(viewModel.pendingApprovals) { booking in
                ApprovalCard(booking: booking) { action in
                    handleApproval(booking: booking, approved: action)
                }
            }
        }
        .padding(DesignSystem.Spacing.m)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
    
    private func handleApproval(booking: PrivateBooking, approved: Bool) {
        withAnimation {
            if approved {
                viewModel.approveBooking(booking.id)
            } else {
                viewModel.rejectBooking(booking.id, reason: "Not available")
            }
        }
    }
    
    // MARK: - My Listings
    
    private var myListingsSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.m) {
            Text("My Listings")
                .font(.headline)
            
            ForEach(viewModel.myListings) { listing in
                ListingManagementCard(listing: listing)
            }
        }
    }
    
    // MARK: - Recent Activity
    
    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.m) {
            Text("Recent Activity")
                .font(.headline)
            
            ForEach(viewModel.bookings.filter { $0.status == .completed }.prefix(5)) { booking in
                ActivityRow(booking: booking, listingName: viewModel.listings.first { $0.id == booking.listingID }?.title ?? "Unknown")
            }
        }
    }
}

// MARK: - Host Stat Card

struct HostStatCard: View {
    let icon: String
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.s) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2.bold())
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(width: 100)
        .padding(DesignSystem.Spacing.m)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Approval Card

struct ApprovalCard: View {
    let booking: PrivateBooking
    let onAction: (Bool) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.m) {
            HStack {
                // Driver avatar
                Circle()
                    .fill(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(String(booking.driverName.prefix(1)))
                            .font(.headline)
                            .foregroundColor(.white)
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(booking.driverName)
                        .font(.subheadline.bold())
                    if let vehicle = booking.vehicleNumber {
                        Text(vehicle)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("₹\(Int(booking.estimatedCost))")
                        .font(.headline)
                        .foregroundColor(.green)
                    Text(booking.durationType.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Time info
            HStack {
                Image(systemName: "clock")
                    .foregroundColor(.secondary)
                Text("\(booking.scheduledStartTime.formatted(date: .abbreviated, time: .shortened))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Message if any
            if let message = booking.driverMessage {
                Text("\"\(message)\"")
                    .font(.caption)
                    .italic()
                    .foregroundColor(.secondary)
                    .padding(.horizontal, DesignSystem.Spacing.s)
                    .padding(.vertical, 4)
                    .background(Color(.tertiarySystemBackground))
                    .cornerRadius(6)
            }
            
            // Action buttons
            HStack(spacing: DesignSystem.Spacing.m) {
                Button {
                    onAction(false)
                } label: {
                    Text("Decline")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, DesignSystem.Spacing.s)
                }
                .buttonStyle(.bordered)
                .tint(.red)
                
                Button {
                    onAction(true)
                } label: {
                    Text("Approve")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, DesignSystem.Spacing.s)
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(DesignSystem.Spacing.m)
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Listing Management Card

struct ListingManagementCard: View {
    let listing: PrivateParkingListing
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.m) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(listing.title)
                        .font(.headline)
                    Text(listing.address)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Slots badge
                HStack(spacing: 4) {
                    Text("\(listing.availableSlots)")
                        .foregroundColor(.green)
                    Text("/")
                        .foregroundColor(.secondary)
                    Text("\(listing.totalSlots)")
                }
                .font(.headline)
            }
            
            // Slot visualization
            HStack(spacing: 4) {
                ForEach(listing.slots) { slot in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(slot.isOccupied ? Color.red.opacity(0.6) : Color.green.opacity(0.6))
                        .frame(height: 20)
                }
            }
            
            // Pricing & Actions
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("₹\(Int(listing.hourlyRate))/hr")
                        .font(.subheadline.bold())
                        .foregroundColor(DesignSystem.Colors.primary)
                    
                    // Competitiveness
                    Label(listing.priceCompetitiveness.rawValue, systemImage: listing.priceCompetitiveness.icon)
                        .font(.caption2)
                        .foregroundColor(listing.priceCompetitiveness.color)
                }
                
                Spacer()
                
                NavigationLink {
                    PricingIntelligenceView(listing: listing)
                } label: {
                    Label("Pricing", systemImage: "chart.line.uptrend.xyaxis")
                        .font(.caption.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(DesignSystem.Colors.primary)
                        .cornerRadius(20)
                }
            }
        }
        .padding(DesignSystem.Spacing.m)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Activity Row

struct ActivityRow: View {
    let booking: PrivateBooking
    let listingName: String
    
    var body: some View {
        HStack {
            Circle()
                .fill(Color.green.opacity(0.2))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: "checkmark")
                        .foregroundColor(.green)
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(booking.driverName)
                    .font(.subheadline.bold())
                Text(listingName)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("+₹\(Int(booking.actualCost ?? booking.estimatedCost))")
                    .font(.subheadline.bold())
                    .foregroundColor(.green)
                Text(booking.scheduledStartTime.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(DesignSystem.Spacing.s)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        PrivateHostDashboardView()
            .environmentObject(PrivateParkingViewModel())
    }
}
