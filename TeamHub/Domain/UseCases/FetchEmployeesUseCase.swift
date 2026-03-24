//
//  FetchEmployeesUseCase.swift
//  TeamHub
//
//  Created by Ayush yadav on 24/03/26.
//

import Foundation

protocol FetchEmployeesUseCase {
    
    func execute(
        query: SearchFilterQuery?,
        page: EmployeePage
    ) async throws -> [Employee]
}

final class DefaultFetchEmployeesUseCase: FetchEmployeesUseCase {
    
    private let repository: EmployeeRepository
    private let syncManager: SyncManager
    private let networkMonitor: NetworkMonitor
    
    init(
        repository: EmployeeRepository,
        syncManager: SyncManager,
        networkMonitor: NetworkMonitor
    ) {
        self.repository = repository
        self.syncManager = syncManager
        self.networkMonitor = networkMonitor
    }
    
    func execute(
        query: SearchFilterQuery?,
        page: EmployeePage
    ) async throws -> [Employee] {
        
        // Trigger sync ONLY for normal list
        if query == nil && networkMonitor.isConnected {
            Task {
                await syncManager.sync()
            }
        }
        
        return try await repository.fetchAll(
            query: query,
            page: page
        )
    }
}
