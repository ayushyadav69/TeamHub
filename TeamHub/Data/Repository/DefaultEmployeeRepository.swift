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
        
        // QUERY FLOW
        
        if let query {
            
            // ONLINE → API ONLY (no caching)
            if networkMonitor.isConnected {
                
                let response = try await remote.fetchEmployees(
                    query: query,
                    page: page
                )
                
                return response.data.map { $0.toEmployee() }
            }
            
            // OFFLINE → DB
            
            let synced = try await local.fetchSynced(
                query: query,
                page: page
            )
            
            // prepend pending only on first page
            if page.page == 0 {
                let pending = try await local.fetchPending(query: query)
                return pending + synced
            }
            
            return synced
        }
        
        // NORMAL FLOW
        
        var synced = try await local.fetchSynced(
            query: nil,
            page: page
        )
        
        // CACHE MISS → FETCH FROM API
        if synced.isEmpty,
           networkMonitor.isConnected {
            
            let response = try await remote.fetchEmployees(
                query: nil,
                page: page
            )
            
            let employees = response.data.map {
                $0.toEmployeeDetail(dateParser: dateParser)
            }
            
            // Save into DB
            for employee in employees {
                try await local.insert(employee, syncStatus: .synced)
            }
            
            // Fetch again from DB
            synced = try await local.fetchSynced(
                query: nil,
                page: page
            )
        }
        
        // Prepend pending only on first page
        if page.page == 1 {
            let pending = try await local.fetchPending(query: nil)
            return pending + synced
        }
        
        return synced
    }
    
    func addEmployee(_ employee: EmployeeDetail) async throws {
        try await local.insert(employee, syncStatus: .created)
    }
    
    func updateEmployee(_ employee: EmployeeDetail) async throws {
        
        // Try finding in DB
        if try await local.exists(id: employee.id) {
            
            // Update existing
            try await local.update(employee)
            
        } else {
            
            // Insert first, then mark as updated
            try await local.insert(employee, syncStatus: .updated)
//            try await local.markAsUpdated(id: employee.id)
        }
    }
    
    func deleteEmployee(id: String) async throws {
        
        if try await local.exists(id: id) {
            
            try await local.delete(id: id)
            
        } else {
            
            // Insert minimal entity, then mark deleted
            try await local.insertDeletedPlaceholder(id: id)
//            try await local.delete(id: id)
        }
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
