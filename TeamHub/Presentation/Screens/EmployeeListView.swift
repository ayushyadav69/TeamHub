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
    
    init(
        container: AppContainer,
        onNavigate: @escaping (Route) -> Void
    ) {
        _viewModel = State(
            wrappedValue: EmployeeListViewModel(
                fetchEmployeesUseCase: container.makeFetchEmployeesUseCase(),
                deleteEmployeeUseCase: container.makeDeleteEmployeeUseCase()
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
            }
        }
        .task {
            await viewModel.loadInitial()
        }
        .navigationTitle("Employees")
        .toolbar {
            Button {
                onNavigate(.add)
            } label: {
                Image(systemName: "plus")
            }
        }
    }
}
