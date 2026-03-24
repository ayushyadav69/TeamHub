//
//  FetchFiltersUseCase.swift
//  TeamHub
//
//  Created by Ayush yadav on 24/03/26.
//

import Foundation

protocol FetchFiltersUseCase {
    func execute() async throws -> Filters
}

final class DefaultFetchFiltersUseCase: FetchFiltersUseCase {
    
    private let repository: EmployeeRepository
    
    init(repository: EmployeeRepository) {
        self.repository = repository
    }
    
    func execute() async throws -> Filters {
        try await repository.fetchFilters()
    }
}
