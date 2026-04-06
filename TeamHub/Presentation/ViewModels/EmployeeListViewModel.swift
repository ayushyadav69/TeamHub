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
    
    private var currentQuery: SearchFilterQuery?
    
    // MARK: - Init
    
    init(
        fetchEmployeesUseCase: FetchEmployeesUseCase,
        deleteEmployeeUseCase: DeleteEmployeeUseCase,
        fetchFiltersUseCase: FetchFiltersUseCase ,
        clearDBSyncUseCase: ClearDBSyncedUseCase
    ) {
        self.fetchEmployeesUseCase = fetchEmployeesUseCase
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
    
    
    func loadInitial() async {
        print("entered initial load")
        guard !isLoading else { return }
        // Prevent reload
        guard !hasLoaded else { return }
        
        hasLoaded = true
        
        isLoading = true
        defer { isLoading = false }
        errorMessage = nil
        
        currentPage = 1
        hasMore = true
        print("entering first page load")
        do {
            print("entered first page load")
            let result = try await fetchEmployeesUseCase.execute(
                query: currentQuery,
                page: EmployeePage(page: currentPage, pageSize: pageSize)
            )
            
            employees = result
            print("Loaded employees count:", result.count)
            let pendingCount = max(0, result.count - pageSize)

            // Only synced count matters
            let syncedCount = result.count - pendingCount

//            hasMore = syncedCount == pageSize
            hasMore = !result.isEmpty
            
        } catch {
            
            //  Ignore cancelled requests
            if (error as? URLError)?.code == .cancelled {
                print(" Request cancelled — ignoring")
                return
            }
            
            errorMessage = (error as? APIError)?.message ?? "Something went wrong"
        }
        
        //        isLoading = false
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
//                hasMore = result.count == pageSize
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
//                employees = []
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
    
    
}
