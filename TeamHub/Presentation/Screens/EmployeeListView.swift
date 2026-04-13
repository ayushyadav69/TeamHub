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
    
    @State private var showFilterSheet = false
    
    init(
        container: AppContainer,
        onNavigate: @escaping (Route) -> Void
    ) {
        _viewModel = State(
            wrappedValue: EmployeeListViewModel(
                fetchEmployeesUseCase: container.makeFetchEmployeesUseCase(),
                manageEmployeeListFiltersUseCase: container.makeManageEmployeeListFiltersUseCase(),
                deleteEmployeeUseCase: container.makeDeleteEmployeeUseCase(),
                fetchFiltersUseCase: container.makeFetchFiltersUseCase(),
                clearDBSyncUseCase: container.makeClearDBSyncUseCase()
            )
        )
        self.onNavigate = onNavigate
    }
    
    var body: some View {
        
        Group {
            
            if (viewModel.isLoading || !viewModel.hasLoaded)
//                && viewModel.employees.isEmpty
            {
                
                VStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                
            } else {
                ZStack {
                    if !viewModel.employees.isEmpty {
                        ScrollViewReader { proxy in
                            List {
                                ForEach(viewModel.employees) { employee in
                                    
                                    EmployeeRowView(employee: employee)
                                        .id(employee.id)
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
                            .scrollDismissesKeyboard(.immediately)
                            .animation(.easeInOut, value: viewModel.isLoadingMore)
                            
                            .refreshable {
                                await viewModel.refresh()
                            }
                            .onChange(of: viewModel.employees.count) { _, _ in
                                
                                if viewModel.currentPage == 1 {
                                    DispatchQueue.main.async {
                                        if let firstId = viewModel.employees.first?.id {
                                            proxy.scrollTo(firstId, anchor: .top)
                                        }
                                    }
                                }
                            }
                        }
                    } else {
                        EmptyStateView(message: viewModel.emptyStateMessage)
                    }
                }
                .searchable(
                    text: Binding(
                        get: { viewModel.searchText },
                        set: { viewModel.setSearchText($0) }
                    )
                )
            }
            
        }
        
        .navigationTitle("Employees")
        .task {
            viewModel.getEmptyStateMessage()
            await viewModel.loadInitial()
            await viewModel.loadFilters()
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
            
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    onNavigate(.add)
                } label: {
                    Image(systemName: "plus")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showFilterSheet = true
                } label: {
                    
                    ZStack(alignment: .topTrailing) {
                        
                        Image(
                            systemName: viewModel.activeFilterCount > 0
                            ? "line.3.horizontal.decrease.circle.fill"
                            : "line.3.horizontal.decrease.circle"
                        )
                        
                        if viewModel.activeFilterCount > 0 {
                            Text("\(viewModel.activeFilterCount)")
                                .font(.caption2)
                                .padding(4)
                                .background(Color.red)
                                .foregroundColor(.white)
                                .clipShape(Circle())
                                .offset(x: 8, y: -8)
                        }
                    }
                }
            }
            
            ToolbarItem(placement: .topBarLeading) {
                NetworkStatusView(text: viewModel.networkStatus)
//                    .padding()
//                    .frame(width: .infinity)
            }
        }
        .sheet(isPresented: $showFilterSheet) {
            
            FilterView(
                initialStatus: viewModel.selectedStatus,
                initialDesignations: viewModel.selectedDesignations,
                initialDepartments: viewModel.selectedDepartments,
                availableDesignations: viewModel.availableDesignations,
                availableDepartments: viewModel.availableDepartments
            ) { newStatus, newDesignations, newDepartments in
                Task {
                    await viewModel.applyFilters(
                        status: newStatus,
                        designations: newDesignations,
                        departments: newDepartments
                    )
                }
            }
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
