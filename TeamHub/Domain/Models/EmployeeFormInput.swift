//
//  EmployeeFormInput.swift
//  TeamHub
//
//  Created by Codex on 07/04/26.
//

import Foundation

struct EmployeeFormInput: Equatable {
    var selectedImageURL: String?
    var name: String
    var email: String
    var designation: String
    var department: String
    var city: String
    var country: String
    var isActive: Bool
    var joiningDate: Date?
    var mobiles: [Mobile]
}

struct EmployeeFormFilterOptions {
    let mobileTypes: [MobileType]
    let designations: [String]
    let departments: [String]
    let selectedDesignation: String
    let selectedDepartment: String
}
