//
//  EmployeeDetailViewModel.swift
//  TeamHub
//
//  Created by Ayush yadav on 25/03/26.
//

import Foundation
import Observation

@MainActor
@Observable
final class EmployeeDetailViewModel {
    
    // MARK: - Dependencies
    
    private let fetchEmployeeDetailUseCase: FetchEmployeeDetailUseCase
    private let deleteEmployeeUseCase: DeleteEmployeeUseCase
    
    // MARK: - State
    
    var employee: EmployeeDetail?
    
    var isLoading = false
    var errorMessage: String?
    
    private var hasLoaded = false
    
    // MARK: - Init
    
    init(
        fetchEmployeeDetailUseCase: FetchEmployeeDetailUseCase,
        deleteEmployeeUseCase: DeleteEmployeeUseCase
    ) {
        self.fetchEmployeeDetailUseCase = fetchEmployeeDetailUseCase
        self.deleteEmployeeUseCase = deleteEmployeeUseCase
    }
    
    func load(id: String) async {
        print("Loading detail for id:", id)
        guard !hasLoaded else { return }
        hasLoaded = true
        
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await fetchEmployeeDetailUseCase.execute(id: id)
            print("Fetched employee:", result)
            employee = result
            print("Employee set:", employee != nil)
        } catch {
            errorMessage = (error as? APIError)?.message ?? "Failed to load"
        }
        
        isLoading = false
    }
    
    func retry(id: String) async {
        hasLoaded = false
        await load(id: id)
    }
    
    func deleteEmployee(id: String) async -> Bool {
        
        do {
            try await deleteEmployeeUseCase.execute(id: id)
            return true
        } catch {
            errorMessage = (error as? APIError)?.message ?? "Delete failed"
            return false
        }
    }
}
