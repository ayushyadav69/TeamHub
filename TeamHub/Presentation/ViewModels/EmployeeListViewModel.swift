//
//  EmployeeListViewModel.swift
//  TeamHub
//
//  Created by Ayush yadav on 24/03/26.
//

import Foundation
import Observation
import SwiftUI

@MainActor
@Observable
final class EmployeeListViewModel {
    
    // MARK: - Dependencies
    
    private let fetchEmployeesUseCase: FetchEmployeesUseCase
    private let manageEmployeeListFiltersUseCase: ManageEmployeeListFiltersUseCase
    private let deleteEmployeeUseCase: DeleteEmployeeUseCase
    private let fetchFiltersUseCase: FetchFiltersUseCase
    private let clearDBSyncUseCase: ClearDBSyncedUseCase
    
    // MARK: - State
    
    var employees: [Employee] = []
    
    var availableDesignations: [String] = []
    var availableDepartments: [String] = []
    
    var isLoading = false
    var isLoadingMore = false
    var errorMessage: String?
    
    private var observerId: UUID?
    private var reloadTask: Task<Void, Never>?
    
    // MARK: - Pagination
    
    private(set) var currentPage = 1
    private let pageSize = 10
    private var hasMore = true
    private(set) var hasLoaded = false
    
    // MARK: - Query
    
    var searchText = ""
    var selectedStatus: Bool? = nil
    var selectedDesignations: [String] = []
    var selectedDepartments: [String] = []

    private var currentQuery: SearchFilterQuery?
    private var searchTask: Task<Void, Never>?
    
    // MARK: - Init
    
    init(
        fetchEmployeesUseCase: FetchEmployeesUseCase,
        manageEmployeeListFiltersUseCase: ManageEmployeeListFiltersUseCase,
        deleteEmployeeUseCase: DeleteEmployeeUseCase,
        fetchFiltersUseCase: FetchFiltersUseCase ,
        clearDBSyncUseCase: ClearDBSyncedUseCase
    ) {
        self.fetchEmployeesUseCase = fetchEmployeesUseCase
        self.manageEmployeeListFiltersUseCase = manageEmployeeListFiltersUseCase
        self.deleteEmployeeUseCase = deleteEmployeeUseCase
        self.fetchFiltersUseCase = fetchFiltersUseCase
        self.clearDBSyncUseCase = clearDBSyncUseCase
        
        observerId = DataChangeNotifier.shared.addObserver { [weak self] in
            
            self?.reloadTask?.cancel()
            
            self?.reloadTask = Task {
                try? await Task.sleep(nanoseconds: 300_000_000)
                self?.hasLoaded = false
                await self?.loadInitial()
            }
        }
    }

    var activeFilterCount: Int {
        manageEmployeeListFiltersUseCase.activeFilterCount(for: currentFilters)
    }

    private var currentFilters: EmployeeListFilters {
        EmployeeListFilters(
            searchText: searchText,
            selectedStatus: selectedStatus,
            selectedDesignations: selectedDesignations,
            selectedDepartments: selectedDepartments
        )
    }
    
    
    func loadInitial() async {
        guard !isLoading else { return }
        guard !hasLoaded else { return }
        
        hasLoaded = true
        
        isLoading = true
        defer { isLoading = false }
        errorMessage = nil
        
        currentPage = 1
        hasMore = true

        do {
            let result = try await fetchEmployeesUseCase.execute(
                query: currentQuery,
                page: EmployeePage(page: currentPage, pageSize: pageSize)
            )
            
            employees = result
            hasMore = !result.isEmpty
            
        } catch {
            
            if (error as? URLError)?.code == .cancelled {
                hasLoaded = false
                return
            }
            
//            hasLoaded = false
            errorMessage = (error as? APIError)?.message ?? "Something went wrong"
        }
    }
    
    func loadNextPage() async {
        
        guard !isLoadingMore, hasMore else { return }
        
        isLoadingMore = true
        
        do {
            let nextPage = currentPage + 1
            
            let result = try await fetchEmployeesUseCase.execute(
                query: currentQuery,
                page: EmployeePage(page: nextPage, pageSize: pageSize)
            )
            
            if !result.isEmpty {
                
                withAnimation {
                    employees.append(contentsOf: result)
                }
                
                currentPage = nextPage
                hasMore = !result.isEmpty
            } else {
                hasMore = false
            }
            
        } catch {
            errorMessage = (error as? APIError)?.message ?? "Failed to load more"
        }
        
        isLoadingMore = false
    }
    
    func loadFilters() async {
        
        do {
            let filters = try await fetchFiltersUseCase.execute()
            
            availableDesignations = filters.designations
            availableDepartments = filters.departments
            
        } catch {
            print(" Failed to load filters:", error)
        }
    }
    
    func refresh() async {
        Task {
            do {
                try await clearDBSyncUseCase.execute()
            } catch {
                print("Unable to clear DB")
            }
            
            hasLoaded = false
            await loadInitial()
        }
    }
    
    func applyQuery(_ query: SearchFilterQuery?) async {
        
        currentQuery = query
        hasLoaded = false
        await loadInitial()
    }

    func setSearchText(_ value: String) {
        searchText = value

        searchTask?.cancel()
        searchTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 900_000_000)

            guard !Task.isCancelled else { return }
            await self?.applyCurrentFilters()
        }
    }

    func applyFilters(
        status: Bool?,
        designations: [String],
        departments: [String]
    ) async {
        selectedStatus = status
        selectedDesignations = designations
        selectedDepartments = departments

        await applyCurrentFilters()
    }
    
    func deleteEmployee(id: String) async {
        
        do {
            try await deleteEmployeeUseCase.execute(id: id)
            
            withAnimation {
                employees.removeAll { $0.id == id }
            }
            
        } catch {
            errorMessage = (error as? APIError)?.message ?? "Delete failed"
        }
    }
    
    func shouldLoadNext(currentItem: Employee) -> Bool {
        
        guard let last = employees.last else { return false }
        
        return last.id == currentItem.id
    }

    private func applyCurrentFilters() async {
        await applyQuery(
            manageEmployeeListFiltersUseCase.buildQuery(from: currentFilters)
        )
    }
    
    
}
