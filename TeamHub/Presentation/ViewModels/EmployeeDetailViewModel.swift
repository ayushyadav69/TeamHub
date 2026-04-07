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
    private(set) var initialLoad = true
    
    private var observerId: UUID?
    private var reloadTask: Task<Void, Never>?
    
    // MARK: - Init
    
    init(
        fetchEmployeeDetailUseCase: FetchEmployeeDetailUseCase,
        deleteEmployeeUseCase: DeleteEmployeeUseCase
    ) {
        self.fetchEmployeeDetailUseCase = fetchEmployeeDetailUseCase
        self.deleteEmployeeUseCase = deleteEmployeeUseCase
        
        observerId = DataChangeNotifier.shared.addObserver { [weak self] in
            
            self?.reloadTask?.cancel()
            
            self?.reloadTask = Task {
                try? await Task.sleep(nanoseconds: 300_000_000)
                self?.hasLoaded = false
                await self?.load(id: self?.employee?.id ?? "")
            }
        }
    }

    func load(id: String) async {
        guard !hasLoaded else { return }
        hasLoaded = true
        
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await fetchEmployeeDetailUseCase.execute(id: id)
            employee = result
        } catch {
            hasLoaded = false
            errorMessage = (error as? APIError)?.message ?? "Failed to load"
        }
        
        isLoading = false
        initialLoad = false
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
