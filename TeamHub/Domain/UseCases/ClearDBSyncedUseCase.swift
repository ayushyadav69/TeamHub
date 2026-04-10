//
//  ClearDBSyncedUseCase.swift
//  TeamHub
//
//  Created by Ayush yadav on 01/04/26.
//

import Foundation

protocol ClearDBSyncedUseCase {
    func execute() async throws
}

final class DefaultClearDBSyncedUseCase: ClearDBSyncedUseCase {
    
    private let repository: EmployeeRepository
    private let networkMonitor: NetworkMonitor
    
    init(repository: EmployeeRepository, networkMonitor: NetworkMonitor) {
        self.repository = repository
        self.networkMonitor = networkMonitor
    }
    
    func execute() async throws {
        if networkMonitor.isConnected {
            try await repository.clearDBSynced()
        }
    }
    
    
}

protocol RefreshServerDataUseCase {
    func execute() async throws
}

final class DefaultRefreshServerDataUseCase: RefreshServerDataUseCase {
    
    private let repository: EmployeeRepository
    private let networkMonitor: NetworkMonitor
    
    init(repository: EmployeeRepository, networkMonitor: NetworkMonitor) {
        self.repository = repository
        self.networkMonitor = networkMonitor
    }
    
    func execute() async throws {
        guard networkMonitor.isConnected else {
            throw APIError.custom("Connect to the internet to refresh from the server.")
        }
        
        try await repository.clearLocalData()
    }
}
