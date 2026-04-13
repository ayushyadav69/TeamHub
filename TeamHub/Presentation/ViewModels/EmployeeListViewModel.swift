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
    
    @ObservationIgnored
    private var retryAction: (@MainActor () async -> Void)?
    
    private var observerId: UUID?
    private var reloadTask: Task<Void, Never>?
    
    // MARK: - Pagination
    
    private(set) var currentPage = 1
    private let pageSize = 20
    private var hasMore = true
    private(set) var hasLoaded = false
    var networkStatus: String = "Online"
    var emptyStateMessage: String = "No Employees"
    
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
        Task {
               while true {
                   await MainActor.run {
                       self.networkStatus = self.getNetworkStatus()
                   }
                   try? await Task.sleep(nanoseconds: 1_000_000_000) // every 1 sec
               }
           }
//        self.networkStatus = getNetworkStatus()
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
            let (result,pageFetched) = try await fetchEmployeesUseCase.execute(
                query: currentQuery,
                page: EmployeePage(page: currentPage, pageSize: pageSize)
            )
            
            employees = result
            hasMore = !result.isEmpty
            currentPage += pageFetched
        } catch {
            
            if (error as? URLError)?.code == .cancelled {
                hasLoaded = false
                return
            }
            
            presentError(
                error,
                fallback: "Something went wrong",
                retryAction: { [weak self] in
                    self?.hasLoaded = false
                    await self?.loadInitial()
                }
            )
        }
    }
    
    func loadNextPage() async {
        
        guard !isLoadingMore, hasMore else { return }
        
        isLoadingMore = true
        
        do {
//            let nextPage = currentPage
            
            let (result,pageFetched) = try await fetchEmployeesUseCase.execute(
                query: currentQuery,
                page: EmployeePage(page: currentPage, pageSize: pageSize)
            )
            
            if !result.isEmpty {
                
                withAnimation {
                    employees.append(contentsOf: result)
                }
                
                currentPage += pageFetched
                hasMore = !result.isEmpty
            } else {
                hasMore = false
            }
            
        } catch {
            presentError(
                error,
                fallback: "Failed to load more",
                retryAction: { [weak self] in
                    await self?.loadNextPage()
                }
            )
        }
        
        isLoadingMore = false
    }
    
    func loadFilters() async {
        
        do {
            let filters = try await fetchFiltersUseCase.forForm()
            
            availableDesignations = filters.designations
            availableDepartments = filters.departments
            
        } catch {
            presentError(
                error,
                fallback: "Failed to load filters",
                retryAction: { [weak self] in
                    await self?.loadFilters()
                }
            )
        }
    }
    
    func refresh() async {
        Task {
//            if currentQuery == nil {
                do {
                    try await clearDBSyncUseCase.execute()
                } catch {
                    print("Unable to clear DB")
                }
//            }
            
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
            presentError(error, fallback: "Delete failed")
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
    
    var canRetryError: Bool {
        retryAction != nil
    }
    
    func dismissError() {
        errorMessage = nil
        retryAction = nil
    }
    
    func retryLastError() {
        guard let retryAction else {
            dismissError()
            return
        }
        
        dismissError()
        
        Task {
            await retryAction()
        }
    }
    
    private func presentError(
        _ error: Error,
        fallback: String,
        retryAction: (@MainActor () async -> Void)? = nil
    ) {
        errorMessage = error.userMessage(fallback: fallback)
        self.retryAction = retryAction
    }
    
    func getNetworkStatus() -> String{
        fetchEmployeesUseCase.getNetworkStatus()
    }
    
    func getEmptyStateMessage() {
        emptyStateMessage = fetchEmployeesUseCase.getEmptyStateMessage()
    }
    
}
