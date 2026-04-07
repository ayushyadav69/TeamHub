import SwiftUI

struct FilterView: View {
    
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: FilterViewModel
    
    let onApply: (Bool?, [String], [String]) -> Void
    
    init(
        initialStatus: Bool?,
        initialDesignations: [String],
        initialDepartments: [String],
        availableDesignations: [String],
        availableDepartments: [String],
        onApply: @escaping (Bool?, [String], [String]) -> Void
    ) {
        _viewModel = State(
            initialValue: FilterViewModel(
                initialStatus: initialStatus,
                initialDesignations: initialDesignations,
                initialDepartments: initialDepartments,
                availableDesignations: availableDesignations,
                availableDepartments: availableDepartments
            )
        )
        self.onApply = onApply
    }
    
    var body: some View {
        
        NavigationStack {
            
            Form {
                FilterOptionsSectionView(
                    title: "Status",
                    options: [true, false],
                    label: { $0 ? "Active" : "Inactive" },
                    isSelected: { viewModel.selectedStatus == $0 },
                    onTap: viewModel.toggleStatus
                )
                
                FilterOptionsSectionView(
                    title: "Designations",
                    options: viewModel.availableDesignations,
                    label: { $0 },
                    isSelected: viewModel.isDesignationSelected,
                    onTap: viewModel.toggleDesignation
                )
                
                FilterOptionsSectionView(
                    title: "Departments",
                    options: viewModel.availableDepartments,
                    label: { $0 },
                    isSelected: viewModel.isDepartmentSelected,
                    onTap: viewModel.toggleDepartment
                )
            }
            .navigationTitle("Filters")
            .toolbar {
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Apply") {
                        onApply(
                            viewModel.selectedStatus,
                            viewModel.selectedDesignations,
                            viewModel.selectedDepartments
                        )
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .bottomBar) {
                    Button("Reset", action: viewModel.reset)
                }
            }
        }
    }
}
