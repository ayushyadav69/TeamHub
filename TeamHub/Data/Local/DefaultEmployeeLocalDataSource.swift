//
//  DefaultEmployeeLocalDataSource.swift
//  TeamHub
//
//  Created by Ayush yadav on 24/03/26.
//

import Foundation

final class DefaultEmployeeLocalDataSource: EmployeeLocalDataSource {
    
    private let dbManager: EmployeeDBManager
    
    init(dbManager: EmployeeDBManager = .shared) {
        self.dbManager = dbManager
    }
    
    func fetchSynced(
        query: SearchFilterQuery?,
        page: EmployeePage
    ) async throws -> [Employee] {
        
        let entities = try dbManager.fetch(query: query, page: page)
        
        return entities.map { $0.toDomain() }
    }
    
    func insert(_ employee: EmployeeDetail, syncStatus: SyncStatus) async throws {
        try dbManager.insert(employee, syncStatus: syncStatus)
    }
    
    func update(_ employee: EmployeeDetail, syncStatus: SyncStatus) async throws {
        try dbManager.update(employee, syncStatus: syncStatus)
    }
    
    func delete(id: String) async throws {
        try dbManager.delete(id: id)
    }
    
    func fetchDetail(id: String) async throws -> EmployeeDetail {
        
        guard let entity = try dbManager.fetchDetail(id: id) else {
            throw NSError(domain: "Employee not found", code: 404)
        }
        
        return entity.toEmployeeDetail()
    }
    
    func fetchFilters() async throws -> Filters {
        try dbManager.fetchFilters()
    }
    
    func fetchPending(
        query: SearchFilterQuery?
    ) async throws -> [Employee] {
        
        let entities = try dbManager.fetchPending(query: query)
        
        return entities.map { $0.toDomain() }
    }
    
    func exists(id: String) async throws -> Bool {
        try dbManager.fetchDetail(id: id) != nil
    }
    
    func markAsUpdated(id: String) async throws {
        
        guard let entity = try dbManager.fetchDetail(id: id) else {
            return
        }
        
        // Do NOT override created
        if entity.syncStatus != SyncStatus.created.rawValue {
            entity.syncStatus = SyncStatus.updated.rawValue
        }
        
        try dbManager.save()
    }
    
    func insertDeletedPlaceholder(id: String) async throws {
        try dbManager.insertDeletedPlaceholder(id: id)
    }
}
