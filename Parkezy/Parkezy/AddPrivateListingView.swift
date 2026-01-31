
import SwiftUI

struct AddPrivateListingView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: PrivateParkingViewModel
    
    // Listing Details
    @State private var title = ""
    @State private var address = ""
    @State private var description = ""
    @State private var slots = 1
    
    // Pricing
    @State private var hourlyRate: Double = 40
    @State private var dailyRate: Double = 300
    @State private var monthlyRate: Double = 3000
    
    // Amenities
    @State private var isCovered = false
    @State private var hasCCTV = false
    @State private var hasEV = false
    
    // Validation
    var isValid: Bool {
        !title.isEmpty && !address.isEmpty && slots > 0
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Basic Details") {
                    TextField("Listing Title", text: $title)
                    TextField("Address", text: $address)
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...5)
                }
                
                Section("Capacity") {
                    Stepper(value: $slots, in: 1...10) {
                        HStack {
                            Text("Number of Slots")
                            Spacer()
                            Text("\(slots)")
                                .fontWeight(.bold)
                                .foregroundColor(DesignSystem.Colors.primary)
                        }
                    }
                }
                
                Section("Default Pricing") {
                    HStack {
                        Text("Hourly Rate")
                        Spacer()
                        TextField("₹", value: $hourlyRate, format: .number)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                    
                    HStack {
                        Text("Daily Rate")
                        Spacer()
                        TextField("₹", value: $dailyRate, format: .number)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                    
                    HStack {
                        Text("Monthly Rate")
                        Spacer()
                        TextField("₹", value: $monthlyRate, format: .number)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                }
                
                Section("Amenities") {
                    Toggle("Covered Parking", isOn: $isCovered)
                    Toggle("CCTV Surveillance", isOn: $hasCCTV)
                    Toggle("EV Charging", isOn: $hasEV)
                }
                
                Section {
                    Button(action: createListing) {
                        Text("Create Listing")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 4)
                    }
                    .disabled(!isValid)
                }
            }
            .navigationTitle("Add New Listing")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func createListing() {
        viewModel.addListing(
            title: title,
            address: address,
            slots: slots,
            hourlyRate: hourlyRate,
            dailyRate: dailyRate,
            monthlyRate: monthlyRate,
            isCovered: isCovered,
            hasCCTV: hasCCTV,
            hasEV: hasEV,
            description: description.isEmpty ? "A great parking spot." : description
        )
        dismiss()
    }
}

#Preview {
    AddPrivateListingView()
        .environmentObject(PrivateParkingViewModel())
}
