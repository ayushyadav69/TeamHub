//
//  UpdateEmployeeUseCase.swift
//  TeamHub
//
//  Created by Ayush yadav on 24/03/26.
//

import Foundation

protocol UpdateEmployeeUseCase {
    func execute(_ employee: EmployeeDetail) async throws
}

final class DefaultUpdateEmployeeUseCase: UpdateEmployeeUseCase {
    
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
    
    func execute(_ employee: EmployeeDetail) async throws {
        
        try await repository.updateEmployee(employee)
        
        if networkMonitor.isConnected {
            Task {
                await syncManager.sync()
            }
        }
    }
}
