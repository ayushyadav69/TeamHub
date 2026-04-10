//
//  EmployeeDetailView.swift
//  TeamHub
//
//  Created by Ayush yadav on 25/03/26.
//

import SwiftUI

struct EmployeeDetailView: View {
    
    @State private var viewModel: EmployeeDetailViewModel
    let id: String
    
    @State private var showDeleteAlert = false
    let onNavigate: (Route) -> Void
    let onDismiss: () -> Void
    let onDeletedDismiss: () -> Void
    
    init(
        container: AppContainer,
        id: String,
        onNavigate: @escaping (Route) -> Void,
        onDismiss: @escaping () -> Void,
        onDeletedDismiss: @escaping () -> Void
    ) {
        self.id = id
        self.onNavigate = onNavigate
        self.onDismiss = onDismiss
        self.onDeletedDismiss = onDeletedDismiss
        
        _viewModel = State(
            initialValue: EmployeeDetailViewModel(
                employeeId: id,
                fetchEmployeeDetailUseCase: container.makeFetchEmployeeDetailUseCase(),
                deleteEmployeeUseCase: container.makeDeleteEmployeeUseCase()
            )
        )
    }
    
    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.initialLoad && viewModel.employee == nil {
                VStack {
                    Spacer()
                    ProgressView()
                        .frame(height: 15)
                    Spacer()
                }
                .id(UUID())
                
            } else if let employee = viewModel.employee {
                EmployeeDetailContentView(employee: employee)
                
            } else {
                VStack {
                    Spacer()
                    Text("No Data Available")
                        .foregroundStyle(.secondary)
                    Spacer()
                }
            }
        }
        .task(id: id) {
            await viewModel.load(id: id)
        }
        .onChange(of: viewModel.shouldDismiss) { _, shouldDismiss in
            if shouldDismiss {
                onDeletedDismiss()
            }
        }
        .alert("Error", isPresented: errorAlertIsPresented) {
            if viewModel.canRetryError {
                Button("Retry") {
                    viewModel.retryLastError()
                }
            }
            
            Button("OK", role: .cancel) {
                viewModel.dismissError()
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .toolbar {
            
            ToolbarItem(placement: .navigationBarTrailing) {
                
                Menu {
                    
                    Button("Edit") {
                        if let employee = viewModel.employee {
                            onNavigate(.edit(employee))
                        }
                    }
                    
                    Button("Delete", role: .destructive) {
                        showDeleteAlert = true
                    }
                    
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .confirmationDialog("Delete Employee?", isPresented: $showDeleteAlert) {
            
            Button("Delete", role: .destructive) {
                Task {
                    if await viewModel.deleteEmployee(id: id) {
                        onDismiss()
                    }
                }
            }
            
            Button("Cancel", role: .cancel) { }
            
        } message: {
            Text("This action cannot be undone.")
        }
    }
    
    private var errorAlertIsPresented: Binding<Bool> {
        Binding(
            get: { viewModel.errorMessage != nil },
            set: { isPresented in
                if !isPresented {
                    viewModel.dismissError()
                }
            }
        )
    }
}
