//
//  EmployeeLocalDataSource.swift
//  TeamHub
//
//  Created by Ayush yadav on 24/03/26.
//

import Foundation

protocol EmployeeLocalDataSource {
    
    func fetchSynced(
            query: SearchFilterQuery?,
            page: EmployeePage
        ) async throws -> [Employee]
    
    func insert(_ employee: EmployeeDetail, syncStatus: SyncStatus) async throws
    func update(_ employee: EmployeeDetail, syncStatus: SyncStatus) async throws
    func delete(id: String) async throws
    
    func fetchDetail(id: String) async throws -> EmployeeDetail?
    func fetchFilters() async throws -> Filters
    
    func fetchPending(
        query: SearchFilterQuery?
    ) async throws -> [Employee]
    
    func insertDeletedPlaceholder(id: String) async throws
    func markAsUpdated(id: String) async throws
    
    // MARK: - Helpers
    
    func exists(id: String) async throws -> Bool
    func deleteAllSynced() async throws
    func deleteAll() async throws
    func updateImage(id: String, url: String) throws
}
