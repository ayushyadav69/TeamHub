//
//  EntityToDomain.swift
//  TeamHub
//
//  Created by Ayush yadav on 24/03/26.
//

import Foundation

extension EmployeeEntity {
    
    func toDomain() -> Employee {
        Employee(
            id: id,
            name: name,
            designation: designation,
            department: department,
            isActive: isActive,
            imageURL: imageURL
        )
    }
}

extension EmployeeEntity {
    
    func toEmployeeDetail() -> EmployeeDetail {
        
        EmployeeDetail(
            id: id,
            name: name,
            email: email,
            designation: designation,
            department: department,
            city: city,
            country: country,
            isActive: isActive,
            imageURL: imageURL,
            joiningDate: joiningDate,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            mobiles: mobiles.map {
                Mobile(
                    id: $0.id,
                    type: MobileType(rawValue: $0.type) ?? .other,
                    number: $0.number
                )
            }
        )
    }
}
