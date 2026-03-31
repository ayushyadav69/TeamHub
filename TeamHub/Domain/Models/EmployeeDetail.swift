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
    let joiningDate: Date
    let createdAt: Date?
    let updatedAt: Date?
    let deletedAt: Date?
    let mobiles: [Mobile]
}

struct Mobile: Hashable, Identifiable {
    let id: String?
    var type: MobileType
    var number: String
}

enum MobileType: String {
    case home
    case office
    case other
}
