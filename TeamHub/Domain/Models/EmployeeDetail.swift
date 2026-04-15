//
//  EmployeeDetail.swift
//  TeamHub
//
//  Created by Ayush yadav on 24/03/26.
//

import Foundation

struct EmployeeDetail: Hashable {
    
    let id: String
    let name: String
    let email: String
    let designation: String
    let department: String
    let city: String
    let country: String
    let isActive: Bool
    var imageURL: String?
    var imageLocalPath: String?
    let joiningDate: Date?
    let createdAt: Date?
    let updatedAt: Date?
    let deletedAt: Date?
    let mobiles: [Mobile]
    let syncStatus: String?
}

struct Mobile: Hashable, Identifiable {
    let id: String?
    var type: MobileType
    var number: String
}

enum MobileType: String, Codable {
    case home
    case office
    case other
}

extension EmployeeDetail {
    
    func toEmployee() -> Employee {
        Employee(
            id: id,
            name: name,
            designation: designation,
            department: department,
            isActive: isActive,
            imageURL: imageURL,
            syncStatus: syncStatus
        )
    }
}
