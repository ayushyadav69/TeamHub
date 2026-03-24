//
//  SyncManager.swift
//  TeamHub
//
//  Created by Ayush yadav on 24/03/26.
//

import Foundation
import SwiftData

final class SyncManager {
    
    private let dbManager: EmployeeDBManager
    private let remote: EmployeeRemoteDataSource
    private let networkMonitor: NetworkMonitor
    
    private var isSyncing = false
    
    init(
        dbManager: EmployeeDBManager,
        remote: EmployeeRemoteDataSource,
        networkMonitor: NetworkMonitor
    ) {
        self.dbManager = dbManager
        self.remote = remote
        self.networkMonitor = networkMonitor
    }
    
    func sync() async {
        
        guard networkMonitor.isConnected else { return }
        guard !isSyncing else { return }
        
        isSyncing = true
        defer { isSyncing = false }
        
        do {
            let pending = try dbManager.fetchPending()
            
            for entity in pending {
                try await syncEntity(entity)
            }
            
        } catch {
            print("Sync failed: \(error)")
        }
    }
    
    private func syncEntity(_ entity: EmployeeEntity) async throws {
        
        do {
            switch entity.syncStatus {
                
            case SyncStatus.created.rawValue:
                
                let newID = try await remote.createEmployee(
                    dbManager.toEmployeeDetail(entity)
                )
                
                try dbManager.replaceID(oldID: entity.id, newID: newID)
                
            case SyncStatus.updated.rawValue:
                try await remote.updateEmployee(
                    dbManager.toEmployeeDetail(entity)
                )
                
            case SyncStatus.deleted.rawValue:
                try await remote.deleteEmployee(id: entity.id)
                
            default:
                return
            }
            
            try handleSuccess(entity)
            
        } catch {
            try handleError(entity: entity, error: error)
        }
    }
    
    private func handleSuccess(_ entity: EmployeeEntity) throws {
        
        if entity.syncStatus == SyncStatus.deleted.rawValue {
            dbManager.deletePermanent(entity)
        } else {
            entity.syncStatus = SyncStatus.synced.rawValue
        }
        
        try dbManager.save()
    }
    
    private func handleError(
        entity: EmployeeEntity,
        error: Error
    ) throws {
        
        guard let apiError = error as? APIError else {
            return // retry later
        }
        
        if apiError.isValidationError {
            
            switch entity.syncStatus {
                
            case SyncStatus.created.rawValue:
                    dbManager.deletePermanent(entity)
                    
            case SyncStatus.deleted.rawValue:
                    dbManager.deletePermanent(entity)
                    
            case SyncStatus.updated.rawValue:
                    // keep it (or mark error later)
                    break
                    
            default:
                    break
            }
            
            try dbManager.save()
        }
    }
}
