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
    ) async throws -> (_:[Employee],pageFetched: Int) {
        
        var pagesFetched = 1
        // QUERY FLOW
//        print("Api offset = ", page.offset)
        if let query {
            
            // ONLINE → API ONLY (no caching)
            if networkMonitor.isConnected {
                let result = try await fetchQueryListFromAPI(query: query, page: page, pagesFetched: pagesFetched)
                return result
            }
            
            // OFFLINE → DB
            
            let synced = try await local.fetchSynced(
                query: query,
                page: page
            )
            
            // prepend pending only on first page
            if page.page == 1 {
                let pending = try await local.fetchPending(query: query)
                let result = pending + synced
                return (result,pageFetched: 1)
            }
            
            return (synced,pageFetched: 1)
        }
        
        // NORMAL FLOW
        
        var synced = try await local.fetchSynced(
            query: nil,
            page: page
        )
        
        if synced.isEmpty, networkMonitor.isConnected {
            (synced,pagesFetched) = try await fetchNormalListFromAPI(page: page,pagesFetched: pagesFetched)
            
        }
        
        // Prepend pending only on first page
        if page.page == 1 {
            let pending = try await local.fetchPending(query: nil)
            let result = pending + synced
            return (result,pageFetched: pagesFetched)
        }
        
        return (synced,pageFetched: pagesFetched)
    }
    
    private func fetchQueryListFromAPI(query: SearchFilterQuery, page: EmployeePage,pagesFetched: Int) async throws -> (_:[Employee],pageFetched: Int) {
        
        
        let response = try await remote.fetchEmployees(
            query: query,
            page: page
        )
        if response.data.isEmpty {
            return ([],pageFetched:pagesFetched)
        }
        let result = response.data.filter{ $0.deletedAt == "" }
        if result.isEmpty {
            let nextPage = EmployeePage(page: page.page + 1, pageSize: page.pageSize)
            return try await fetchQueryListFromAPI(query: query, page: nextPage,pagesFetched: pagesFetched + 1)
        }
        
        return (result.map { $0.toEmployee() },pageFetched: pagesFetched)
        
    }
    
    private func fetchNormalListFromAPI(page: EmployeePage,pagesFetched: Int) async throws -> (employees:[Employee],pageFetched: Int) {
        
        
        
        // CACHE MISS → FETCH FROM API
        let response = try await remote.fetchEmployees(
            query: nil,
            page: page
        )
        
        if page.page == 1 {
            cursorStore.save(response.meta.latestUpdatedSeq)
        }
        
        if response.data.isEmpty {
            return ([],pageFetched:pagesFetched)
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
            return try await fetchNormalListFromAPI(page: nextPage,pagesFetched: pagesFetched + 1)
        }
        
        return (synced, pageFetched: pagesFetched)
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
        DataChangeNotifier.shared.notifyEmployeeDeleted(id: id)
        DataChangeNotifier.shared.notify()
    }
    
    func fetchDetail(id: String) async throws -> EmployeeDetail {
        
        let employee = try await local.fetchDetail(id: id)
        guard let employee else {
            if networkMonitor.isConnected {
                
                let response = try await remote.fetchEmployeeDetail(id: id)
                
                return response.data.toEmployeeDetail(dateParser: dateParser, dateParserISO: dateParserISO)
            }
            throw APIError.custom("Employee does not exist.")
        }
        
        return employee
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
    
    func clearLocalData() async throws {
        try await local.deleteAll()
        cursorStore.clear()
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
