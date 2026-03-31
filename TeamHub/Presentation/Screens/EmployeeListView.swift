//
//  EmployeeListView.swift
//  TeamHub
//
//  Created by Ayush yadav on 24/03/26.
//

import SwiftUI

struct EmployeeListView: View {
    
    @State private var viewModel: EmployeeListViewModel
    let onNavigate: (Route) -> Void
    
    @State private var searchText: String = ""
    @State private var searchTask: Task<Void, Never>?
    @State private var showFilterSheet = false
    @State private var selectedStatus: Bool? = nil
    @State private var selectedDesignations: [String] = []
    @State private var selectedDepartments: [String] = []
    
    init(
        container: AppContainer,
        onNavigate: @escaping (Route) -> Void
    ) {
        _viewModel = State(
            wrappedValue: EmployeeListViewModel(
                fetchEmployeesUseCase: container.makeFetchEmployeesUseCase(),
                deleteEmployeeUseCase: container.makeDeleteEmployeeUseCase(),
                fetchFiltersUseCase: container.makeFetchFiltersUseCase()
            )
        )
        self.onNavigate = onNavigate
    }
    
    var body: some View {
        
        Group {
            
            if viewModel.isLoading {
                
                VStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                
            } else if let error = viewModel.errorMessage {
                
                VStack(spacing: 12) {
                    
                    Text(error)
                        .multilineTextAlignment(.center)
                    
                    Button("Retry") {
                        Task {
                            await viewModel.loadInitial()
                        }
                    }
                }
                .padding()
                
            } else {
                
                List {
                    
                    ForEach(viewModel.employees, id: \.id) { employee in
                        
                        EmployeeRowView(employee: employee)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                onNavigate(.detail(employee.id))
                            }
                            .onAppear {
                                if viewModel.shouldLoadNext(currentItem: employee) {
                                    Task {
                                        await viewModel.loadNextPage()
                                    }
                                }
                            }
                    }
                    
                    // Footer Loader
                    if viewModel.isLoadingMore {
                        
                        HStack {
                            Spacer()
                            ProgressView()
                                .frame(height: 50)
                            Spacer()
                        }
                        .id(UUID())
                    }
                }
                .listStyle(.plain)
                .animation(.easeInOut, value: viewModel.isLoadingMore)
                .searchable(text: $searchText)
                .onChange(of: searchText) { _, newValue in
                    
                    searchTask?.cancel()
                    
                    searchTask = Task {
                        
                        try? await Task.sleep(nanoseconds: 900_000_000) // 900ms
                        
                        if Task.isCancelled { return }
                        
                        await viewModel.applyQuery(buildQuery())
                    }
                }
                .refreshable {
                    await viewModel.refresh()
                }
            }
        }
        .task {
            await viewModel.loadInitial()
            await viewModel.loadFilters()
        }
        .navigationTitle("Employees")
        .toolbar {
            Button {
                onNavigate(.add)
            } label: {
                Image(systemName: "plus")
            }
            
            Button {
                showFilterSheet = true
            } label: {
                Image(systemName: "line.3.horizontal.decrease.circle")
            }
        }
        .sheet(isPresented: $showFilterSheet) {
            
            FilterView(
                initialStatus: selectedStatus,
                initialDesignations: selectedDesignations,
                initialDepartments: selectedDepartments,
                availableDesignations: viewModel.availableDesignations,
                availableDepartments: viewModel.availableDepartments
            ) { newStatus, newDesignations, newDepartments in
                
                selectedStatus = newStatus
                selectedDesignations = newDesignations
                selectedDepartments = newDepartments
                
                Task {
                    await viewModel.applyQuery(buildQuery())
                }
            }
        }
    }
}

private extension EmployeeListView {
//    private func applySearch(_ text: String) async {
//        
//        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
//        
//        let query = trimmed.isEmpty
//            ? nil
//        : SearchFilterQuery(searchText: trimmed, isActive: nil)
//        
//        await viewModel.applyQuery(query)
//    }
    
    private func buildQuery() -> SearchFilterQuery? {
        
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let hasSearch = !trimmed.isEmpty
        let hasStatus = selectedStatus != nil
        let hasDesignations = !selectedDesignations.isEmpty
        let hasDepartments = !selectedDepartments.isEmpty
        
        let hasFilters = hasStatus || hasDesignations || hasDepartments
        
        guard hasSearch || hasFilters else { return nil }
        
        return SearchFilterQuery(
            searchText: hasSearch ? trimmed : nil,
            designations: selectedDesignations,
            departments: selectedDepartments,
            isActive: selectedStatus
        )
    }
}
