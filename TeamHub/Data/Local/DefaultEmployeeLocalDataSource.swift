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
    
    func fetch(
        query: SearchFilterQuery?,
        page: EmployeePage
    ) async throws -> [Employee] {
        
        let entities = try dbManager.fetch(query: query, page: page)
        
        return entities.map { $0.toDomain() }
    }
    
    func insert(_ employee: EmployeeDetail) async throws {
        try dbManager.insert(employee)
    }
    
    func update(_ employee: EmployeeDetail) async throws {
        try dbManager.update(employee)
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
}
