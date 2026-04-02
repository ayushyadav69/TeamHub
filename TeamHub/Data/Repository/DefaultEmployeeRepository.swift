//
//  DefaultEmployeeRepository.swift
//  TeamHub
//
//  Created by Ayush yadav on 24/03/26.
//

import Foundation

final class DefaultEmployeeRepository: EmployeeRepository {
    
    private let remote: EmployeeRemoteDataSource
    private let local: EmployeeLocalDataSource
    private let networkMonitor: NetworkMonitor
    private let dateParser: DateParsing
    private let dateParserISO: DateParsing
    private let imageUploader: ImageUploader
    private let cursorStore: CursorStore
    private let filtersCache: FiltersCache
    
    init(
        remote: EmployeeRemoteDataSource,
        local: EmployeeLocalDataSource,
        networkMonitor: NetworkMonitor,
        dateParser: DateParsing,
        dateParserISO: DateParsing,
        imageUploader: ImageUploader,
        cursorStore: CursorStore,
        filtersCache: FiltersCache
    ) {
        self.remote = remote
        self.local = local
        self.networkMonitor = networkMonitor
        self.dateParser = dateParser
        self.dateParserISO = dateParserISO
        self.imageUploader = imageUploader
        self.cursorStore = cursorStore
        self.filtersCache = filtersCache
    }
    
    func fetchAll(
        query: SearchFilterQuery?,
        page: EmployeePage
    ) async throws -> [Employee] {
        
        // QUERY FLOW
        
        if let query {
            
            // ONLINE → API ONLY (no caching)
            if networkMonitor.isConnected {
                
                let response = try await remote.fetchEmployees(
                    query: query,
                    page: page
                )
                let result = response.data.filter{ $0.deletedAt == "" }
                return result.map { $0.toEmployee() }
            }
            
            // OFFLINE → DB
            
            let synced = try await local.fetchSynced(
                query: query,
                page: page
            )
            
            // prepend pending only on first page
            if page.page == 0 {
                let pending = try await local.fetchPending(query: query)
                return pending + synced
            }
            
            return synced
        }
        
        // NORMAL FLOW
        
        var synced = try await local.fetchSynced(
            query: nil,
            page: page
        )
        
        if synced.isEmpty, networkMonitor.isConnected {
            synced = try await fetchNormalListFromAPI(page: page)
        }
        
        // Prepend pending only on first page
        if page.page == 1 {
            let pending = try await local.fetchPending(query: nil)
            return pending + synced
        }
        
        return synced
    }
    
    private func fetchNormalListFromAPI(page: EmployeePage) async throws -> [Employee] {
        
        
        
        // CACHE MISS → FETCH FROM API
        let response = try await remote.fetchEmployees(
            query: nil,
            page: page
        )
        
        if page.page == 1 {
            cursorStore.save(response.meta.latestUpdatedSeq)
        }
        
        if response.data.isEmpty {
            return []
        }
        
        let employees = response.data.map {
            $0.toEmployeeDetail(dateParser: dateParser, dateParserISO: dateParserISO)
        }
        
        // Save into DB
        for employee in employees {
            try await local.insert(employee, syncStatus: .synced)
        }
        
        // Fetch again from DB
        let synced = try await local.fetchSynced(
            query: nil,
            page: page
        )
        
        if synced.isEmpty {
            let nextPage = EmployeePage(page: page.page + 1, pageSize: page.pageSize)
            return try await fetchNormalListFromAPI(page: nextPage)
        }
        
        return synced
    }
    
    func addEmployee(_ form: EmployeeFormData) async throws {
        
        var employee = form.employee
        
        // STEP 1: Upload image if exists
        if let data = form.imageData {
            do {
                let url = try await imageUploader.upload(data)
                
                employee.imageURL = url
                employee.imageLocalPath = nil
                
            } catch {
                // OFFLINE fallback
                let path = ImageStorage.save(data)
                
                employee.imageURL = nil
                employee.imageLocalPath = path
            }
        }
        
        // STEP 2: Save to DB FIRST (offline-first)
        try await local.insert(employee, syncStatus: .created)
        DataChangeNotifier.shared.notify()
        // STEP 3: Mark for sync (SyncManager handles API)
    }
    
    func updateEmployee(_ form: EmployeeFormData) async throws {
        
        var employee = form.employee
        
        // STEP 1: Upload image if exists
        if let data = form.imageData {
            do {
                let url = try await imageUploader.upload(data)
                
                employee.imageURL = url
                employee.imageLocalPath = nil
                
            } catch {
                // OFFLINE fallback
                let path = ImageStorage.save(data)
                
                employee.imageURL = nil
                employee.imageLocalPath = path
            }
        }
        
        // Try finding in DB
        if try await local.exists(id: employee.id) {
            
            // Update existing
            try await local.update(employee, syncStatus: .updated)
            
        } else {
            
            // Insert first, then mark as updated
            try await local.insert(employee, syncStatus: .updated)
//            try await local.markAsUpdated(id: employee.id)
        }
        DataChangeNotifier.shared.notify()
    }
    
    func deleteEmployee(id: String) async throws {
        
        if try await local.exists(id: id) {
            
            try await local.delete(id: id)
            
        } else {
            
            // Insert minimal entity, then mark deleted
            try await local.insertDeletedPlaceholder(id: id)
//            try await local.delete(id: id)
        }
        DataChangeNotifier.shared.notify()
    }
    
    func fetchDetail(id: String) async throws -> EmployeeDetail {
        
        if networkMonitor.isConnected {
            
            let response = try await remote.fetchEmployeeDetail(id: id)
            
            return response.data.toEmployeeDetail(dateParser: dateParser, dateParserISO: dateParserISO)
        }
        
        return try await local.fetchDetail(id: id)
    }
    
    func fetchFilters() async throws -> Filters {
        
        if networkMonitor.isConnected {
            
            let response = try await remote.fetchFilters()
            
            let filters = response.data.toDomain()
            filtersCache.save(filters)
            
            return filters
        }
        
        return try await local.fetchFilters()
    }
    
    func fetchFiltersForForm() async throws -> Filters {
        if let cache = filtersCache.load() {
            return cache
        }
        
        let response = try await remote.fetchFilters()
        
        return response.data.toDomain()
    }
    
    func clearDBSynced() async throws {
        try await local.deleteAllSynced()
    }
    
    func uploadPendingImages() async {
        
        guard let employees = try? await local.fetchPending(query: nil) else { return }
        
        for emp in employees {
            
            guard let path = emp.imageLocalPath,
                  let data = ImageStorage.load(path: path)
            else { continue }
            
            do {
                let url = try await imageUploader.upload(data)
                
                try local.updateImage(id: emp.id, url: url)
                
            } catch {
                // still offline → ignore
            }
        }
    }
}
