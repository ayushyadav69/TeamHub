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
//    private let container: AppContainer
    
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
        content
            .onAppear {
                print("DetailView Appeared")
                Task {
                    await viewModel.load(id: id)
                }
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
                    deleteEmployee()
                }
                
                Button("Cancel", role: .cancel) { }
                
            } message: {
                Text("This action cannot be undone.")
            }
    }
}

private extension EmployeeDetailView {
    
    @ViewBuilder
    var content: some View {
        
        if viewModel.isLoading && viewModel.initialLoad {
            loadingView
            
        } else if let error = viewModel.errorMessage {
            errorView(message: error)
            
        } else if let employee = viewModel.employee {
            detailView(employee)
        } else {
            emptyState
        }
    }
}

private extension EmployeeDetailView {
    var loadingView: some View {
        VStack {
            Spacer()
            ProgressView()
                .frame(height: 15)
            Spacer()
        }
        .id(UUID())
    }
    
    var emptyState: some View {
        VStack {
            Spacer()
            Text("No Data Available")
                .foregroundStyle(.secondary)
            Spacer()
        }
    }
    
    func errorView(message: String) -> some View {
        VStack(spacing: 12) {
            
            Text(message)
                .multilineTextAlignment(.center)
            
            Button("Retry") {
                Task {
                    await viewModel.retry(id: id)
                }
            }
        }
        .padding()
    }
    
    func detailView(_ employee: EmployeeDetail) -> some View {
        
        ScrollView {
            
            VStack(spacing: 20) {
                
                headerSection(employee)
                
                infoSection(employee)
                
                phoneSection(employee)
            }
            .padding()
        }
    }
    
    private func headerSection(_ employee: EmployeeDetail) -> some View {
        
        VStack(spacing: 12) {
            
            profileImage(employee)
            
            Text(employee.name)
                .font(.title2)
                .fontWeight(.semibold)
            
            Text(employee.email)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
    
    private func profileImage(_ employee: EmployeeDetail) -> some View {
        
        Group {
            if let path = employee.imageLocalPath,
               let data = ImageStorage.load(path: path),
               let uiImage = UIImage(data: data) {
                
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                
            } else {
                
                CachedAsyncImage(url: URL(string: employee.imageURL ?? "")) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Circle()
                        .fill(Color.secondary.opacity(0.2))
                }
                .id(employee.imageURL)
                .frame(width: 100, height: 100)
                .clipShape(Circle())
            }
        }
    }
    
    private func infoSection(_ employee: EmployeeDetail) -> some View {
        
        VStack(alignment: .leading, spacing: 12) {
            
            infoRow(title: "Designation", value: employee.designation)
            
            infoRow(title: "Department", value: employee.department)
            
            infoRow(
                title: "Location",
                value: "\(employee.city), \(employee.country)"
            )
            
            if let date = employee.joiningDate {
                infoRow(title: "Joining Date", value: date.formatted(date: .numeric, time: .omitted))
            }
            
            statusRow(employee)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func infoRow(title: String, value: String) -> some View {
        
        VStack(alignment: .leading, spacing: 4) {
            
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Text(value)
                .font(.body)
        }
    }
    
    private func statusRow(_ employee: EmployeeDetail) -> some View {
        
        HStack {
            
            Text("Status")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            Text(employee.isActive ? "Active" : "Inactive")
                .font(.caption)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(
                    employee.isActive
                    ? Color.green.opacity(0.15)
                    : Color.secondary.opacity(0.15)
                )
                .clipShape(Capsule())
        }
    }
    
    private func phoneSection(_ employee: EmployeeDetail) -> some View {
        
        VStack(alignment: .leading, spacing: 12) {
            
            Text("Phone Numbers")
                .font(.headline)
            
            if employee.mobiles.isEmpty {
                
                Text("No phone numbers available")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
            } else {
                
                ForEach(employee.mobiles, id: \.id) { mobile in
                    phoneRow(mobile)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func phoneRow(_ mobile: Mobile) -> some View {
        
        HStack {
            
            VStack(alignment: .leading, spacing: 2) {
                
                Text(mobile.type.rawValue.capitalized)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text(mobile.number)
                    .font(.body)
            }
            
            Spacer()
        }
    }
    
    private func deleteEmployee() {
        
        guard let id = viewModel.employee?.id else { return }
        
        Task {
            let success = await viewModel.deleteEmployee(id: id)
            
            if success {
                onDismiss()
            }
        }
    }
}
