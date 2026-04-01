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
    private let dateParser: DateParsing
    private let dateParserISO: DateParsing
    private let cursorStore: CursorStore
    
    private var syncTask: Task<Void, Never>?
    
    private var isSyncing = false
    
    init(
        dbManager: EmployeeDBManager,
        remote: EmployeeRemoteDataSource,
        networkMonitor: NetworkMonitor,
        dateParser: DateParsing,
        dateParserISO: DateParsing,
        cursorStore: CursorStore
    ) {
        self.dbManager = dbManager
        self.remote = remote
        self.networkMonitor = networkMonitor
        self.dateParser = dateParser
        self.dateParserISO = dateParserISO
        self.cursorStore = cursorStore
    }
    
    func sync() async {
        
        guard networkMonitor.isConnected else { return }
        guard !isSyncing else { return }
        
        isSyncing = true
        defer { isSyncing = false }
        
        do {
            let pending = try dbManager.fetchPending()
            
            let batchSize = 4

            for chunk in pending.chunked(into: batchSize) {
                
                await withTaskGroup(of: Void.self) { group in
                    
                    for entity in chunk {
                        group.addTask {
                            do {
                                try await self.syncEntity(entity)
                                print("Employee pushed to server")
                            } catch {
                                print("Sync error for \(entity.id): \(entity.name) = ", error)
                            }
                        }
                    }
                }
            }
            
        } catch {
            print("Sync failed: \(error)")
        }
    }
    
    private func syncEntity(_ entity: EmployeeEntity) async throws {
        
        do {
            switch entity.syncStatus {
                
            case SyncStatus.created.rawValue:
                print("above created employee")
                let newID = try await remote.createEmployee(
                    dbManager.toEmployeeDetail(entity)
                )
                print("below created employee")
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
//            dbManager.deletePermanent(entity)
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
    
    func pullSync() async {
        
        guard networkMonitor.isConnected else { return }
        guard let cursor = cursorStore.get() else { return }
        
        do {
            try await performSync(cursor: cursor)
        } catch {
            print(" Pull sync failed:", error)
        }
    }
    
    private func performSync(cursor: Int) async throws {
        
        let response = try await remote.sync(cursor: cursor)
        
        try dbManager.applyServerChanges(response.employees.map { $0.toEmployeeDetail(dateParser: dateParser, dateParserISO: dateParserISO)})
        
        cursorStore.save(response.nextCursor.seq)
//        try context.save()
        DataChangeNotifier.shared.notify()
        
//        if response.hasMore {
//            try await performSync(cursor: response.nextCursor.seq)
//        }
    }
    
    func startAutoSync() {
        
        guard syncTask == nil else { return }
        
        guard !isSyncing else { return }
        
        isSyncing = true
        defer { isSyncing = false }
        
        syncTask = Task {
            
            while !Task.isCancelled {
                
//                await sync()
                await pullSync()
                
                try? await Task.sleep(nanoseconds: 5_000_000_000) // 5 sec
            }
        }
    }
    
    func stopAutoSync() {
        syncTask?.cancel()
        syncTask = nil
    }
}

extension Array {
    
    func chunked(into size: Int) -> [[Element]] {
        
        stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}
