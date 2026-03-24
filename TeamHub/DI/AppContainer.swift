//
//  AppContainer.swift
//  TeamHub
//
//  Created by Ayush yadav on 24/03/26.
//

import Foundation
import SwiftUI

final class AppContainer {
    
    // MARK: - Core
    
    lazy var apiClient: APIClient = {
        URLSessionAPIClient()
    }()
    
    lazy var networkMonitor: NetworkMonitor = {
        DefaultNetworkMonitor()
    }()
    
    lazy var dateParser: DateParsing = {
        DefaultDateParser()
    }()
    
    lazy var apiDateFormatter: DateFormatting = {
        DefaultAPIDateFormatter()
    }()
    
    // MARK: - DB
    
    lazy var employeeDBManager: EmployeeDBManager = {
        EmployeeDBManager.shared
    }()
    
    // MARK: - Local
    
    lazy var employeeLocalDataSource: EmployeeLocalDataSource = {
        DefaultEmployeeLocalDataSource(
            dbManager: employeeDBManager
        )
    }()
    
    // MARK: - Remote
    
    lazy var employeeRemoteDataSource: EmployeeRemoteDataSource = {
        DefaultEmployeeRemoteDataSource(
            apiClient: apiClient,
            dateFormatter: apiDateFormatter
        )
    }()
    
    // MARK: - Repository
    
    lazy var employeeRepository: EmployeeRepository = {
        DefaultEmployeeRepository(
            remote: employeeRemoteDataSource,
            local: employeeLocalDataSource,
            networkMonitor: networkMonitor,
            dateParser: dateParser
        )
    }()
    
    // MARK: - Sync
    
    lazy var syncManager: SyncManager = {
        SyncManager(
            dbManager: employeeDBManager,
            remote: employeeRemoteDataSource,
            networkMonitor: networkMonitor
        )
    }()
}

extension AppContainer {
    
    // MARK: - Fetch Employees
    
    func makeFetchEmployeesUseCase() -> FetchEmployeesUseCase {
        DefaultFetchEmployeesUseCase(
            repository: employeeRepository,
            syncManager: syncManager,
            networkMonitor: networkMonitor
        )
    }
    
    // MARK: - Fetch Detail
    
    func makeFetchEmployeeDetailUseCase() -> FetchEmployeeDetailUseCase {
        DefaultFetchEmployeeDetailUseCase(
            repository: employeeRepository
        )
    }
    
    // MARK: - Fetch Filters
    
    func makeFetchFiltersUseCase() -> FetchFiltersUseCase {
        DefaultFetchFiltersUseCase(
            repository: employeeRepository
        )
    }
    
    // MARK: - Add
    
    func makeAddEmployeeUseCase() -> AddEmployeeUseCase {
        DefaultAddEmployeeUseCase(
            repository: employeeRepository,
            syncManager: syncManager,
            networkMonitor: networkMonitor
        )
    }
    
    // MARK: - Update
    
    func makeUpdateEmployeeUseCase() -> UpdateEmployeeUseCase {
        DefaultUpdateEmployeeUseCase(
            repository: employeeRepository,
            syncManager: syncManager,
            networkMonitor: networkMonitor
        )
    }
    
    // MARK: - Delete
    
    func makeDeleteEmployeeUseCase() -> DeleteEmployeeUseCase {
        DefaultDeleteEmployeeUseCase(
            repository: employeeRepository,
            syncManager: syncManager,
            networkMonitor: networkMonitor
        )
    }
}
