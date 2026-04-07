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
    
    init(
        container: AppContainer,
        id: String,
        onNavigate: @escaping (Route) -> Void,
        onDismiss: @escaping () -> Void
    ) {
        self.id = id
        self.onNavigate = onNavigate
        self.onDismiss = onDismiss
        
        _viewModel = State(
            initialValue: EmployeeDetailViewModel(
                fetchEmployeeDetailUseCase: container.makeFetchEmployeeDetailUseCase(),
                deleteEmployeeUseCase: container.makeDeleteEmployeeUseCase()
            )
        )
    }
    
    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.initialLoad {
                VStack {
                    Spacer()
                    ProgressView()
                        .frame(height: 15)
                    Spacer()
                }
                .id(UUID())
                
            } else if let error = viewModel.errorMessage {
                VStack(spacing: 12) {
                    
                    Text(error)
                        .multilineTextAlignment(.center)
                    
                    Button("Retry") {
                        Task {
                            await viewModel.retry(id: id)
                        }
                    }
                }
                .padding()
                
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
        .alert("Delete Employee?", isPresented: $showDeleteAlert) {
            
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
}
