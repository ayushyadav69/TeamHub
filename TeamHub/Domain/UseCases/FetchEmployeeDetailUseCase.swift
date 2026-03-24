//
//  FetchEmployeeDetailUseCase.swift
//  TeamHub
//
//  Created by Ayush yadav on 24/03/26.
//

import Foundation

protocol FetchEmployeeDetailUseCase {
    func execute(id: String) async throws -> EmployeeDetail
}

final class DefaultFetchEmployeeDetailUseCase: FetchEmployeeDetailUseCase {
    
    private let repository: EmployeeRepository
    
    init(repository: EmployeeRepository) {
        self.repository = repository
    }
    
    func execute(id: String) async throws -> EmployeeDetail {
        try await repository.fetchDetail(id: id)
    }
}
