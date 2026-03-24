//
//  DeleteEmployeeUseCase.swift
//  TeamHub
//
//  Created by Ayush yadav on 24/03/26.
//

import Foundation

protocol DeleteEmployeeUseCase {
    func execute(id: String) async throws
}

final class DefaultDeleteEmployeeUseCase: DeleteEmployeeUseCase {
    
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
    
    func execute(id: String) async throws {
        
        try await repository.deleteEmployee(id: id)
        
        if networkMonitor.isConnected {
            Task {
                await syncManager.sync()
            }
        }
    }
}
