//
//  DefaultEmployeeRemoteDataSource.swift
//  TeamHub
//
//  Created by Ayush yadav on 24/03/26.
//

import Foundation

final class DefaultEmployeeRemoteDataSource: EmployeeRemoteDataSource {
    
    private let apiClient: APIClient
        private let dateFormatter: DateFormatting
        
        init(
            apiClient: APIClient,
            dateFormatter: DateFormatting
        ) {
            self.apiClient = apiClient
            self.dateFormatter = dateFormatter
        }
    
    func fetchEmployees(
        query: SearchFilterQuery?,
        page: EmployeePage
    ) async throws -> EmployeeListResponseDTO {
        
        let request = FetchEmployeesRequest(
            query: query,
            page: page
        )
        
        return try await apiClient.send(request)
    }
    
    func fetchEmployeeDetail(id: String) async throws -> EmployeeDetailResponseDTO {
        
        let request = FetchEmployeeDetailRequest(id: id)
        
        return try await apiClient.send(request)
    }
    
    func createEmployee(_ employee: EmployeeDetail) async throws -> String {
        
        let dto = employee.toRequestDTO(dateFormatter: dateFormatter)
        
        let request = CreateEmployeeRequest(dto: dto)
        
        let response = try await apiClient.send(request)
        
        return response.data.id
    }

    func updateEmployee(_ employee: EmployeeDetail) async throws {
        
        let dto = employee.toRequestDTO(dateFormatter: dateFormatter)
        
        let request = UpdateEmployeeRequest(id: employee.id, dto: dto)
        
        _ = try await apiClient.send(request)
    }

    func deleteEmployee(id: String) async throws {
        let request = DeleteEmployeeRequest(id: id)
        _ = try await apiClient.send(request)
    }

    func fetchFilters() async throws -> FiltersResponseDTO {
        let request = FetchFiltersRequest()
        return try await apiClient.send(request)
    }
}
