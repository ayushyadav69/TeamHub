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
    
    lazy var curserStore: CursorStore = {
        CursorStore()
    }()
    
    lazy var dateParser: DateParsing = {
        DefaultDateParser()
    }()
    
    lazy var dateParserISO: DateParsing = {
        DefaultAPIDateParserISO()
    }()
    
    lazy var apiDateFormatter: DateFormatting = {
        DefaultAPIDateFormatter()
    }()
    
    lazy var apiDateFormatterISO: DateFormatting = {
        DefaultAPIDateFormatterISO()
    }()
    
    lazy var imageUploader: ImageUploader = {
        CloudinaryImageUploader(cloudName: "dovot7suo", uploadPreset: "siynhyo9")
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
            dateFormatter: apiDateFormatter,
            dateFormatterISO: apiDateFormatterISO
        )
    }()
    
    // MARK: - Repository
    
    lazy var employeeRepository: EmployeeRepository = {
        DefaultEmployeeRepository(
            remote: employeeRemoteDataSource,
            local: employeeLocalDataSource,
            networkMonitor: networkMonitor,
            dateParser: dateParser,
            dateParserISO: dateParserISO,
            imageUploader: imageUploader,
            cursorStore: curserStore
        )
    }()
    
    // MARK: - Sync
    
    lazy var syncManager: SyncManager = {
        SyncManager(
            dbManager: employeeDBManager,
            remote: employeeRemoteDataSource,
            networkMonitor: networkMonitor,
            dateParser: dateParser,
            dateParserISO: dateParserISO,
            cursorStore: curserStore
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
    
    func makeClearDBSyncUseCase() -> ClearDBSyncedUseCase {
        DefaultClearDBSyncedUseCase(repository: employeeRepository, networkMonitor: networkMonitor)
    }
    
    func setupNetworkSync() {
        
        networkMonitor.onReconnect = { [weak self] in
            
            guard let self else { return }
            
            Task {
                print(" Reconnected → triggering sync")
                
                await self.syncManager.sync()
//                await self.syncManager.pullSync()
            }
        }
    }
}
