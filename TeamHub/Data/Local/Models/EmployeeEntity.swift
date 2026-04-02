//
//  EmployeeEntity.swift
//  TeamHub
//
//  Created by Ayush yadav on 24/03/26.
//

import Foundation
import SwiftData

@Model
final class EmployeeEntity {
    
    @Attribute(.unique)
    var id: String
    
    var name: String
    var designation: String
    var department: String
    var isActive: Bool
    var imageURL: String?
    var imageLocalPath: String?
    var email: String
    var city: String
    var country: String
    var joiningDate: Date
    
    // IMPORTANT (sync support)
    var syncStatus: String
//    var isDeleted: Bool
    var createdAt: Date?
    var updatedAt: Date?
    var deletedAt: Date?
    
    @Relationship(deleteRule: .cascade, inverse: \MobileEntity.employee)
    var mobiles: [MobileEntity]
    
    init(
        id: String,
        name: String,
        designation: String,
        department: String,
        isActive: Bool,
        imageURL: String?,
        imageLocalPath: String?,
        email: String,
        city: String,
        country: String,
        joiningDate: Date,
        mobiles: [MobileEntity],
        syncStatus: String,
        createdAt: Date?,
        updatedAt: Date?,
        deletedAt: Date?
    ) {
        self.id = id
        self.name = name
        self.designation = designation
        self.department = department
        self.isActive = isActive
        self.imageURL = imageURL
        self.imageLocalPath = imageLocalPath
        self.email = email
        self.city = city
        self.country = country
        self.joiningDate = joiningDate
        self.mobiles = mobiles
        self.syncStatus = syncStatus
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }
}
