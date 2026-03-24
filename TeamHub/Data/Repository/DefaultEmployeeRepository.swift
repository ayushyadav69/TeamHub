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
        
        // CASE 2: Default OR Offline
        return try await local.fetch(query: query, page: page)
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
