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
    ) async throws -> (_:[Employee],pageFetched: Int)
    func getNetworkStatus() -> String
    func getEmptyStateMessage() -> String
    var onReconnect: (() -> Void)? { get set }
}

final class DefaultFetchEmployeesUseCase: FetchEmployeesUseCase {
    
    private let repository: EmployeeRepository
    private let syncManager: SyncManager
    private var networkMonitor: NetworkMonitor
    var onReconnect: (() -> Void)?
    
    init(
        repository: EmployeeRepository,
        syncManager: SyncManager,
        networkMonitor: NetworkMonitor
    ) {
        self.repository = repository
        self.syncManager = syncManager
        self.networkMonitor = networkMonitor
        let existingHandler = networkMonitor.onReconnect
        self.networkMonitor.onReconnect = { [weak self] in
            existingHandler?()
            self?.onReconnect?()
        }
    }
    
    func execute(
        query: SearchFilterQuery?,
        page: EmployeePage
    ) async throws -> (_:[Employee],pageFetched: Int) {
        
        // Trigger sync ONLY for normal list
//        if query == nil && networkMonitor.isConnected {
//            Task {
//                await syncManager.sync()
//            }
//        }
        
        return try await repository.fetchAll(
            query: query,
            page: page
        )
    }
    
    func getNetworkStatus() -> String {
        if networkMonitor.isConnected {
            return "Online"
        }
        return "Offline"
    }
    
    func getEmptyStateMessage() -> String {
        if networkMonitor.isConnected {
            return "No Employees"
        }
        return """
        No Employees 
        You are Offline, May have employees on server.
        """
    }
    
}
