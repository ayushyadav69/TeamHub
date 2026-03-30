//
//  EmployeeRepository.swift
//  TeamHub
//
//  Created by Ayush yadav on 24/03/26.
//

import Foundation

protocol EmployeeRepository {
    
    func fetchAll(
        query: SearchFilterQuery?,
        page: EmployeePage
    ) async throws -> [Employee]
    
    func fetchDetail(id: String) async throws -> EmployeeDetail
    func fetchFilters() async throws -> Filters
    
    func addEmployee(_ employee: EmployeeFormData) async throws
    func updateEmployee(_ employee: EmployeeFormData) async throws
    func deleteEmployee(id: String) async throws
}
