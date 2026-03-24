//
//  EmployeeDetail.swift
//  TeamHub
//
//  Created by Ayush yadav on 24/03/26.
//

import Foundation

struct EmployeeDetail {
    
    let id: String
    let name: String
    let email: String
    let designation: String
    let department: String
    let city: String
    let country: String
    let isActive: Bool
    let imageURL: String?
    let joiningDate: Date
    let mobiles: [Mobile]
}

struct Mobile {
    let id: String?
    let type: MobileType
    let number: String
}

enum MobileType: String {
    case home
    case office
    case other
}
