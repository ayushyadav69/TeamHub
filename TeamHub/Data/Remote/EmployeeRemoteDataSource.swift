//
//  EmployeeRemoteDataSource.swift
//  TeamHub
//
//  Created by Ayush yadav on 24/03/26.
//

import Foundation

protocol EmployeeRemoteDataSource {
    
    func fetchEmployees(
        query: SearchFilterQuery?,
        page: EmployeePage
    ) async throws -> EmployeeListResponseDTO
    
    func fetchEmployeeDetail(id: String) async throws -> EmployeeDetailResponseDTO
    
    func createEmployee(_ employee: EmployeeDetail) async throws -> String
    func updateEmployee(_ employee: EmployeeDetail) async throws
    func deleteEmployee(id: String) async throws
    func fetchFilters() async throws -> FiltersResponseDTO
}
