//
//  AddEmployeeUseCase.swift
//  TeamHub
//
//  Created by Ayush yadav on 24/03/26.
//

import Foundation

protocol AddEmployeeUseCase {
    func execute(_ employeeForm: EmployeeFormData) async throws
}

final class DefaultAddEmployeeUseCase: AddEmployeeUseCase {
    
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
    
    func execute(_ employeeForm: EmployeeFormData) async throws {
        
        try await repository.addEmployee(employeeForm)
        
        if networkMonitor.isConnected {
            Task {
                await syncManager.sync()
            }
        }
    }
}
