import SwiftUI

struct FilterView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - State
    
    let initialStatus: Bool?
    @State private var selectedStatus: Bool?
    
    let initialDesignations: [String]
    let availableDesignations: [String]
    
    @State private var selectedDesignations: Set<String>
    
    let initialDepartments: [String]
    let availableDepartments: [String]

    @State private var selectedDepartments: Set<String>
    
    // MARK: - Callback
    
    let onApply: (Bool?, [String], [String]) -> Void
    
    init(
        initialStatus: Bool?,
        initialDesignations: [String],
        initialDepartments: [String],
        availableDesignations: [String],
        availableDepartments: [String],
        onApply: @escaping (Bool?, [String], [String]) -> Void
    ) {
        self.initialStatus = initialStatus
        self.initialDesignations = initialDesignations
        self.initialDepartments = initialDepartments
        self.availableDesignations = availableDesignations
        self.availableDepartments = availableDepartments
        
        self._selectedStatus = State(initialValue: initialStatus)
        self._selectedDesignations = State(initialValue: Set(initialDesignations))
        self._selectedDepartments = State(initialValue: Set(initialDepartments))
        
        self.onApply = onApply
    }
    
    var body: some View {
        
        NavigationStack {
            
            Form {
                
                statusSection
                designationSection
                departmentSection
//                Section("Status") {
//                    Toggle("Active Only", isOn: $isActiveOnly)
//                }
            }
            .navigationTitle("Filters")
            .toolbar {
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Apply") {
                        onApply(selectedStatus, Array(selectedDesignations), Array(selectedDepartments))
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

private extension FilterView {
    private var statusSection: some View {
        Section("Status") {
            
            Button {
                toggleStatus(true)
            } label: {
                row("Active", isSelected: selectedStatus == true)
            }
            
            Button {
                toggleStatus(false)
            } label: {
                row("Inactive", isSelected: selectedStatus == false)
            }
        }
    }
    
    private var designationSection: some View {
        Section("Designations") {
            
            ForEach(availableDesignations, id: \.self) { designation in
                
                Button {
                    toggleDesignation(designation)
                } label: {
                    row(designation, isSelected: selectedDesignations.contains(designation))
                }
            }
        }
    }
    
    private var departmentSection: some View {
        Section("Departments") {
            
            ForEach(availableDepartments, id: \.self) { dept in
                
                Button {
                    toggleDepartment(dept)
                } label: {
                    row(dept, isSelected: selectedDepartments.contains(dept))
                }
            }
        }
    }
    
    private func toggleDepartment(_ value: String) {
        if selectedDepartments.contains(value) {
            selectedDepartments.remove(value)
        } else {
            selectedDepartments.insert(value)
        }
    }
    
    private func toggleDesignation(_ value: String) {
        if selectedDesignations.contains(value) {
            selectedDesignations.remove(value)
        } else {
            selectedDesignations.insert(value)
        }
    }
    
    private func toggleStatus(_ value: Bool) {
        if selectedStatus == value {
            selectedStatus = nil   // deselect → no filter
        } else {
            selectedStatus = value
        }
    }
    
    private func row(_ title: String, isSelected: Bool) -> some View {
        HStack {
            Text(title)
            Spacer()
            if isSelected {
                Image(systemName: "checkmark")
            }
        }
    }
}
