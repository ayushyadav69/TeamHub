//
//  EmployeeDBManager.swift
//  TeamHub
//
//  Created by Ayush yadav on 24/03/26.
//

import Foundation
import SwiftData

final class EmployeeDBManager {
    
    static let shared = EmployeeDBManager()
    
    private let context: ModelContext
    
    private init() {
        self.context = ModelContext(SharedModelContainer.container)
    }
}

extension EmployeeDBManager {
    
    func insert(_ employee: EmployeeDetail, syncStatus: SyncStatus) throws {
        
        let entity = EmployeeEntity(
            id: employee.id,
            name: employee.name,
            designation: employee.designation,
            department: employee.department,
            isActive: employee.isActive,
            imageURL: employee.imageURL,
            email: employee.email,
            city: employee.city,
            country: employee.country,
            joiningDate: employee.joiningDate,
            mobiles: (employee.mobiles).map {
                MobileEntity(
                    id: $0.id,
                    type: $0.type.rawValue,
                    number: $0.number
                )
            },
            syncStatus: syncStatus.rawValue,
            isDeleted: false
        )
        
        context.insert(entity)
        try context.save()
    }
    
    func update(_ employee: EmployeeDetail) throws {
        
        let id = employee.id
        let descriptor = FetchDescriptor<EmployeeEntity>(
            predicate: #Predicate { $0.id == id }
        )
        
        guard let entity = try context.fetch(descriptor).first else {
            return
        }
        
        entity.name = employee.name
        entity.designation = employee.designation
        entity.department = employee.department
        entity.isActive = employee.isActive
        entity.imageURL = employee.imageURL
        entity.email = employee.email
        entity.city = employee.city
        entity.country = employee.country
        entity.joiningDate = employee.joiningDate
        
        entity.mobiles = employee.mobiles.map {
            MobileEntity(
                id: $0.id,
                type: $0.type.rawValue,
                number: $0.number
            )
        }
        
        // Sync logic
        if entity.syncStatus != SyncStatus.created.rawValue {
            entity.syncStatus = SyncStatus.updated.rawValue
        } 
        
        try context.save()
    }
    
    func delete(id: String) throws {
        
        let descriptor = FetchDescriptor<EmployeeEntity>(
            predicate: #Predicate { $0.id == id }
        )
        
        guard let entity = try context.fetch(descriptor).first else {
            return
        }
        
        entity.isDeleted = true
        entity.syncStatus = SyncStatus.deleted.rawValue
        
        try context.save()
    }
    
    func fetch(
        query: SearchFilterQuery?,
        page: EmployeePage
    ) throws -> [EmployeeEntity] {
        
        let search = query?.searchText?
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        let deptArray = query?.departments ?? []
        let designationArray = query?.designations ?? []
        let isActive = query?.isActive
        
        let predicate = #Predicate<EmployeeEntity> { entity in
            
            !entity.isDeleted && entity.syncStatus == "synced"
            
            &&
            (search == nil || entity.name.localizedStandardContains(search!))
            
            &&
            (deptArray.isEmpty || deptArray.contains(entity.department))
            
            &&
            (designationArray.isEmpty || designationArray.contains(entity.designation))
            
            &&
            (
                isActive == nil
                ||
                entity.isActive == isActive!
            )
        }
        
        var descriptor = FetchDescriptor<EmployeeEntity>(
            predicate: predicate
//            sortBy: [
//                SortDescriptor(\.name),
//                SortDescriptor(\.id)
//            ]
        )
        
        descriptor.fetchLimit = page.pageSize
        descriptor.fetchOffset = page.offset
        
        return try context.fetch(descriptor)
    }
    
    func fetchDetail(id: String) throws -> EmployeeEntity? {
        
        let idValue = id
        
        let descriptor = FetchDescriptor<EmployeeEntity>(
            predicate: #Predicate { $0.id == idValue }
        )
        
        return try context.fetch(descriptor).first
    }
    
    func fetchFilters() throws -> Filters {
        
        let descriptor = FetchDescriptor<EmployeeEntity>(
            predicate: #Predicate { !$0.isDeleted }
        )
        
        let employees = try context.fetch(descriptor)
        
        let designations = Set(employees.map { $0.designation })
        let departments = Set(employees.map { $0.department })
        
        let hasActive = employees.contains { $0.isActive }
        let hasInactive = employees.contains { !$0.isActive }
        
        var statuses: [StatusFilter] = []
        
        if hasActive {
            statuses.append(StatusFilter(label: "Active", value: true))
        }
        
        if hasInactive {
            statuses.append(StatusFilter(label: "Inactive", value: false))
        }
        
        return Filters(
            designations: Array(designations).sorted(),
            departments: Array(departments).sorted(),
            statuses: statuses,
            mobileTypes: [.home, .office, .other] // static
        )
    }
    
    func fetchPending() throws -> [EmployeeEntity] {
        
        let descriptor = FetchDescriptor<EmployeeEntity>(
            predicate: #Predicate { $0.syncStatus != "synced" }
        )
        
        return try context.fetch(descriptor)
    }
    
    func save() throws {
        try context.save()
    }
    
    func deletePermanent(_ entity: EmployeeEntity) {
        context.delete(entity)
    }
    
    func toEmployeeDetail(_ entity: EmployeeEntity) -> EmployeeDetail {
        entity.toEmployeeDetail()
    }
    
    func replaceID(oldID: String, newID: String) throws {
        
        let oldValue = oldID
        
        let descriptor = FetchDescriptor<EmployeeEntity>(
            predicate: #Predicate { $0.id == oldValue }
        )
        
        guard let entity = try context.fetch(descriptor).first else { return }
        
        entity.id = newID
        
        try context.save()
    }
    
    func fetchPending(
        query: SearchFilterQuery?
    ) throws -> [EmployeeEntity] {
        
        let search = query?.searchText?
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        let deptArray = query?.departments ?? []
        let designationArray = query?.designations ?? []
        let isActive = query?.isActive
        
        let predicate = #Predicate<EmployeeEntity> { entity in
            
            // ONLY pending
            entity.syncStatus != "synced"
            &&
            !entity.isDeleted
            
            // SEARCH
            &&
            (search == nil || entity.name.localizedStandardContains(search!))
            
            // DEPARTMENT
            &&
            (deptArray.isEmpty || deptArray.contains(entity.department))
            
            // DESIGNATION
            &&
            (designationArray.isEmpty || designationArray.contains(entity.designation))
            
            // STATUS
            &&
            (
                isActive == nil
                ||
                entity.isActive == isActive!
            )
        }
        
        let descriptor = FetchDescriptor<EmployeeEntity>(
            predicate: predicate
//            sortBy: [
//                SortDescriptor(\.name),
//                SortDescriptor(\.id)
//            ]
        )
        
        return try context.fetch(descriptor)
    }
    
    func insertDeletedPlaceholder(id: String) throws {
        
        let entity = EmployeeEntity(
            id: id,
            name: "",
            designation: "",
            department: "",
            isActive: false,
            imageURL: "",
            email: "",
            city: "",
            country: "",
            joiningDate: Date(),
            mobiles: [],
            syncStatus: SyncStatus.deleted.rawValue,
            isDeleted: true
        )
        
        context.insert(entity)
        try context.save()
    }
}
