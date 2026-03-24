//
//  DefaultEmployeeRepository.swift
//  TeamHub
//
//  Created by Ayush yadav on 24/03/26.
//

import Foundation

final class DefaultEmployeeRepository: EmployeeRepository {
    
    private let remote: EmployeeRemoteDataSource
    private let local: EmployeeLocalDataSource
    private let networkMonitor: NetworkMonitor
    private let dateParser: DateParsing
    
    init(
        remote: EmployeeRemoteDataSource,
        local: EmployeeLocalDataSource,
        networkMonitor: NetworkMonitor,
        dateParser: DateParsing
    ) {
        self.remote = remote
        self.local = local
        self.networkMonitor = networkMonitor
        self.dateParser = dateParser
    }
    
    func fetchAll(
        query: SearchFilterQuery?,
        page: EmployeePage
    ) async throws -> [Employee] {
        
        // CASE 1: Search / Filter
        if let query, networkMonitor.isConnected {
            
            let response = try await remote.fetchEmployees(
                query: query,
                page: page
            )
            
            return response.data.map { $0.toEmployee() }
        }
        
        // CASE 2: Normal list (DB-first)
        
        let localData = try await local.fetch(query: nil, page: page)
        
        // If DB has data → return it
        if !localData.isEmpty {
            return localData
        }
        
        // If DB empty AND online → fetch from API
        if networkMonitor.isConnected {
            
            let response = try await remote.fetchEmployees(
                query: nil,
                page: page
            )
            
            let employees = response.data.map { $0.toEmployeeDetail(dateParser: dateParser) }
            
            // Save to DB
            for employee in employees {
                try await local.insert(employee)
            }
            
            // Return from DB (single source of truth)
            return try await local.fetch(query: nil, page: page)
        }
        
        return []
    }
    
    func addEmployee(_ employee: EmployeeDetail) async throws {
        try await local.insert(employee)
    }
    
    func updateEmployee(_ employee: EmployeeDetail) async throws {
        try await local.update(employee)
    }
    
    func deleteEmployee(id: String) async throws {
        try await local.delete(id: id)
    }
    
    func fetchDetail(id: String) async throws -> EmployeeDetail {
        
        if networkMonitor.isConnected {
            
            let response = try await remote.fetchEmployeeDetail(id: id)
            
            return response.data.toEmployeeDetail(dateParser: dateParser)
        }
        
        return try await local.fetchDetail(id: id)
    }
    
    func fetchFilters() async throws -> Filters {
        
        if networkMonitor.isConnected {
            
            let response = try await remote.fetchFilters()
            
            return response.data.toDomain()
        }
        
        return try await local.fetchFilters()
    }
}
