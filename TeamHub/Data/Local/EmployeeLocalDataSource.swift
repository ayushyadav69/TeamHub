//
//  EmployeeLocalDataSource.swift
//  TeamHub
//
//  Created by Ayush yadav on 24/03/26.
//

import Foundation

protocol EmployeeLocalDataSource {
    
    func fetch(
            query: SearchFilterQuery?,
            page: EmployeePage
        ) async throws -> [Employee]
    
    func insert(_ employee: EmployeeDetail) async throws
    func update(_ employee: EmployeeDetail) async throws
    func delete(id: String) async throws
    
    func fetchDetail(id: String) async throws -> EmployeeDetail
    func fetchFilters() async throws -> Filters
}
