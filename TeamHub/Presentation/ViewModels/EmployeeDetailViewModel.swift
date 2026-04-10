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
    
    private let employeeId: String
    private let fetchEmployeeDetailUseCase: FetchEmployeeDetailUseCase
    private let deleteEmployeeUseCase: DeleteEmployeeUseCase
    
    // MARK: - State
    
    var employee: EmployeeDetail?
    
    var isLoading = false
    var errorMessage: String?
    var shouldDismiss = false
    
    @ObservationIgnored
    private var retryAction: (@MainActor () async -> Void)?
    
    private var hasLoaded = false
    private(set) var initialLoad = true
    
    private var observerId: UUID?
    private var deletedEmployeeObserverId: UUID?
    private var reloadTask: Task<Void, Never>?
    
    // MARK: - Init
    
    init(
        employeeId: String,
        fetchEmployeeDetailUseCase: FetchEmployeeDetailUseCase,
        deleteEmployeeUseCase: DeleteEmployeeUseCase
    ) {
        self.employeeId = employeeId
        self.fetchEmployeeDetailUseCase = fetchEmployeeDetailUseCase
        self.deleteEmployeeUseCase = deleteEmployeeUseCase
        
        observerId = DataChangeNotifier.shared.addObserver { [weak self] in
            
            self?.reloadTask?.cancel()
            
            self?.reloadTask = Task {
                try? await Task.sleep(nanoseconds: 300_000_000)
                guard self?.shouldDismiss != true else { return }
                self?.hasLoaded = false
                await self?.load(id: self?.employeeId ?? "")
            }
        }
        
        deletedEmployeeObserverId = DataChangeNotifier.shared
            .addDeletedEmployeeObserver { [weak self] deletedEmployeeId in
                guard deletedEmployeeId == self?.employeeId else { return }
                
                Task { @MainActor [weak self] in
                    self?.shouldDismiss = true
                }
            }
    }
    
    deinit {
        MainActor.assumeIsolated {
            if let observerId {
                DataChangeNotifier.shared.removeObserver(observerId)
            }
            
            if let deletedEmployeeObserverId {
                DataChangeNotifier.shared.removeObserver(deletedEmployeeObserverId)
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
            presentError(
                error,
                fallback: "Failed to load",
                retryAction: { [weak self] in
                    self?.hasLoaded = false
                    await self?.load(id: self?.employeeId ?? id)
                }
            )
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
            presentError(error, fallback: "Delete failed")
            return false
        }
    }
    
    var canRetryError: Bool {
        retryAction != nil
    }
    
    func dismissError() {
        errorMessage = nil
        retryAction = nil
    }
    
    func retryLastError() {
        guard let retryAction else {
            dismissError()
            return
        }
        
        dismissError()
        
        Task {
            await retryAction()
        }
    }
    
    private func presentError(
        _ error: Error,
        fallback: String,
        retryAction: (@MainActor () async -> Void)? = nil
    ) {
        errorMessage = error.userMessage(fallback: fallback)
        self.retryAction = retryAction
    }
}
