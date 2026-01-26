//
//  HostDashboardView.swift
//  ParkEzy
//
//  Host dashboard with earnings cards and SwiftCharts integration
//

import SwiftUI
import Charts

struct HostDashboardView: View {
    // MARK: - Environment
    
    @EnvironmentObject var hostViewModel: HostViewModel
    
    // MARK: - State
    
    @State private var showQRScanner = false
    @State private var selectedTimeRange: TimeRange = .week
    @State private var animateCharts = false
    
    // MARK: - Body
    
    var body: some View {
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.l) {
                // MARK: - Welcome Header
                
                welcomeHeader
                
                // MARK: - Earnings Cards
                
                earningsCards
                
                // MARK: - Quick Actions
                
                quickActionsSection
                
                // MARK: - Revenue Chart
                
                revenueChart
                
                // MARK: - Peak Hours Chart
                
                peakHoursChart
                
                // MARK: - Booking Distribution
                
                bookingDistributionChart
                
                // MARK: - Active Bookings
                
                activeBookingsSection
            }
            .padding(DesignSystem.Spacing.m)
        }
        .navigationTitle("Dashboard")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showQRScanner = true
                } label: {
                    Image(systemName: "qrcode.viewfinder")
                        .font(.title2)
                        .foregroundColor(DesignSystem.Colors.primary)
                }
            }
        }
        .sheet(isPresented: $showQRScanner) {
            QRScannerView(isPresented: $showQRScanner)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8).delay(0.2)) {
                animateCharts = true
            }
        }
        .refreshable {
            hostViewModel.refreshDashboard()
        }
    }
    
    // MARK: - Welcome Header
    
    private var welcomeHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Welcome back,")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(hostViewModel.currentHost?.name ?? "Host")
                    .font(.title.bold())
            }
            
            Spacer()
            
            // Profile Avatar
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [DesignSystem.Colors.primary, DesignSystem.Colors.primary.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 50, height: 50)
                
                Text(String(hostViewModel.currentHost?.name.prefix(1) ?? "H"))
                    .font(.title2.bold())
                    .foregroundColor(.white)
            }
        }
        .padding(DesignSystem.Spacing.m)
        .background(Color(.systemBackground))
        .cornerRadius(DesignSystem.Spacing.m)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
    
    // MARK: - Earnings Cards
    
    private var earningsCards: some View {
        HStack(spacing: DesignSystem.Spacing.m) {
            // Today's Earnings
            EarningsCard(
                icon: "indianrupeesign.circle.fill",
                title: "Today",
                value: "₹\(Int(hostViewModel.todayEarnings))",
                trend: "+12%",
                trendPositive: true,
                color: DesignSystem.Colors.success
            )
            
            // Total Earnings
            EarningsCard(
                icon: "chart.line.uptrend.xyaxis",
                title: "Total",
                value: "₹\(formatEarnings(hostViewModel.totalEarnings))",
                trend: nil,
                trendPositive: true,
                color: DesignSystem.Colors.primary
            )
            
            // Active Bookings
            EarningsCard(
                icon: "car.fill",
                title: "Active",
                value: "\(hostViewModel.activeBookingCount)",
                trend: nil,
                trendPositive: true,
                color: .orange
            )
        }
    }
    
    // MARK: - Quick Actions
    
    private var quickActionsSection: some View {
        HStack(spacing: DesignSystem.Spacing.m) {
            QuickHostAction(icon: "qrcode.viewfinder", title: "Scan Entry") {
                showQRScanner = true
            }
            
            QuickHostAction(icon: "list.bullet.rectangle", title: "All Bookings") {
                // Navigate to bookings list
            }
            
            QuickHostAction(icon: "gearshape.fill", title: "Settings") {
                // Navigate to settings
            }
        }
    }
    
    // MARK: - Revenue Chart
    
    private var revenueChart: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.m) {
            HStack {
                Text("Revenue")
                    .font(.headline)
                
                Spacer()
                
                // Time Range Picker
                Picker("Range", selection: $selectedTimeRange) {
                    ForEach(TimeRange.allCases, id: \.self) { range in
                        Text(range.rawValue).tag(range)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 180)
            }
            
            Chart {
                ForEach(hostViewModel.revenueData) { data in
                    LineMark(
                        x: .value("Day", data.formattedDate),
                        y: .value("Revenue", animateCharts ? data.amount : 0)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [DesignSystem.Colors.primary, DesignSystem.Colors.primary.opacity(0.5)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round))
                    .interpolationMethod(.catmullRom)
                    
                    AreaMark(
                        x: .value("Day", data.formattedDate),
                        y: .value("Revenue", animateCharts ? data.amount : 0)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                DesignSystem.Colors.primary.opacity(0.3),
                                DesignSystem.Colors.primary.opacity(0.0)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .interpolationMethod(.catmullRom)
                    
                    PointMark(
                        x: .value("Day", data.formattedDate),
                        y: .value("Revenue", animateCharts ? data.amount : 0)
                    )
                    .foregroundStyle(DesignSystem.Colors.primary)
                    .symbolSize(60)
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisValueLabel {
                        if let amount = value.as(Double.self) {
                            Text("₹\(Int(amount))")
                                .font(.caption)
                        }
                    }
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [5]))
                        .foregroundStyle(Color.gray.opacity(0.3))
                }
            }
            .chartXAxis {
                AxisMarks { value in
                    AxisValueLabel()
                        .font(.caption)
                }
            }
            .frame(height: 200)
            .animation(.easeOut(duration: 0.8), value: animateCharts)
        }
        .padding(DesignSystem.Spacing.m)
        .background(Color(.systemBackground))
        .cornerRadius(DesignSystem.Spacing.m)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
    
    // MARK: - Peak Hours Chart
    
    private var peakHoursChart: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.m) {
            Text("Peak Hours")
                .font(.headline)
            
            Chart {
                ForEach(hostViewModel.peakHoursData) { data in
                    BarMark(
                        x: .value("Hour", data.displayTime),
                        y: .value("Bookings", animateCharts ? data.count : 0)
                    )
                    .foregroundStyle(
                        data.count > 3 ? DesignSystem.Colors.primary :
                            data.count > 1 ? DesignSystem.Colors.primary.opacity(0.6) :
                            Color.gray.opacity(0.3)
                    )
                    .cornerRadius(4)
                }
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: 2)) { value in
                    AxisValueLabel()
                        .font(.caption2)
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            .frame(height: 150)
            .animation(.easeOut(duration: 0.8).delay(0.1), value: animateCharts)
            
            // Legend
            HStack(spacing: DesignSystem.Spacing.l) {
                HStack(spacing: 4) {
                    Circle().fill(DesignSystem.Colors.primary).frame(width: 8, height: 8)
                    Text("High demand")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack(spacing: 4) {
                    Circle().fill(DesignSystem.Colors.primary.opacity(0.6)).frame(width: 8, height: 8)
                    Text("Medium")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack(spacing: 4) {
                    Circle().fill(Color.gray.opacity(0.3)).frame(width: 8, height: 8)
                    Text("Low")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(DesignSystem.Spacing.m)
        .background(Color(.systemBackground))
        .cornerRadius(DesignSystem.Spacing.m)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
    
    // MARK: - Booking Distribution Chart
    
    private var bookingDistributionChart: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.m) {
            Text("Booking Distribution")
                .font(.headline)
            
            HStack(spacing: DesignSystem.Spacing.l) {
                // Donut Chart
                Chart {
                    ForEach(hostViewModel.bookingDistribution) { data in
                        SectorMark(
                            angle: .value("Count", animateCharts ? data.percentage : 0),
                            innerRadius: .ratio(0.6),
                            angularInset: 2
                        )
                        .foregroundStyle(data.color)
                        .cornerRadius(4)
                    }
                }
                .frame(width: 120, height: 120)
                .animation(.easeOut(duration: 0.8).delay(0.2), value: animateCharts)
                
                // Legend
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.s) {
                    ForEach(hostViewModel.bookingDistribution) { data in
                        HStack(spacing: DesignSystem.Spacing.s) {
                            Circle()
                                .fill(data.color)
                                .frame(width: 12, height: 12)
                            
                            Text(data.type)
                                .font(.subheadline)
                            
                            Spacer()
                            
                            Text("\(data.percentage)%")
                                .font(.subheadline.bold())
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .padding(DesignSystem.Spacing.m)
        .background(Color(.systemBackground))
        .cornerRadius(DesignSystem.Spacing.m)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
    
    // MARK: - Active Bookings Section
    
    private var activeBookingsSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.m) {
            HStack {
                Text("Active Bookings")
                    .font(.headline)
                
                Spacer()
                
                if !hostViewModel.activeBookings.isEmpty {
                    Text("\(hostViewModel.activeBookings.count)")
                        .font(.caption.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(DesignSystem.Colors.success)
                        .clipShape(Capsule())
                }
            }
            
            if hostViewModel.activeBookings.isEmpty {
                VStack(spacing: DesignSystem.Spacing.m) {
                    Image(systemName: "car.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.gray.opacity(0.5))
                    
                    Text("No active bookings")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, DesignSystem.Spacing.xl)
            } else {
                ForEach(hostViewModel.activeBookings) { booking in
                    ActiveBookingRow(booking: booking)
                }
            }
        }
        .padding(DesignSystem.Spacing.m)
        .background(Color(.systemBackground))
        .cornerRadius(DesignSystem.Spacing.m)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
    
    // MARK: - Helper Methods
    
    private func formatEarnings(_ amount: Double) -> String {
        if amount >= 1000 {
            return String(format: "%.1fK", amount / 1000)
        }
        return String(format: "%.0f", amount)
    }
}

// MARK: - Time Range Enum

enum TimeRange: String, CaseIterable {
    case week = "Week"
    case month = "Month"
    case year = "Year"
}

// MARK: - Earnings Card

struct EarningsCard: View {
    let icon: String
    let title: String
    let value: String
    let trend: String?
    let trendPositive: Bool
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.s) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                
                Spacer()
                
                if let trend = trend {
                    Text(trend)
                        .font(.caption.bold())
                        .foregroundColor(trendPositive ? DesignSystem.Colors.success : DesignSystem.Colors.error)
                }
            }
            
            Text(value)
                .font(.title2.bold())
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(DesignSystem.Spacing.m)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .cornerRadius(DesignSystem.Spacing.m)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

// MARK: - Quick Host Action

struct QuickHostAction: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: DesignSystem.Spacing.s) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(DesignSystem.Colors.primary)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignSystem.Spacing.m)
            .background(Color(.systemBackground))
            .cornerRadius(DesignSystem.Spacing.s)
            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
    }
}

// MARK: - Active Booking Row

struct ActiveBookingRow: View {
    let booking: BookingSession
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.m) {
            // Status Indicator
            Circle()
                .fill(DesignSystem.Colors.success)
                .frame(width: 10, height: 10)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Booking #\(booking.id.uuidString.prefix(6).uppercased())")
                    .font(.subheadline.bold())
                
                Text("Ends at \(formatTime(booking.scheduledEndTime))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("₹\(Int(booking.totalCost))")
                .font(.subheadline.bold())
                .foregroundColor(DesignSystem.Colors.primary)
        }
        .padding(DesignSystem.Spacing.s)
        .background(DesignSystem.Colors.success.opacity(0.05))
        .cornerRadius(DesignSystem.Spacing.s)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        HostDashboardView()
            .environmentObject(HostViewModel())
    }
}
