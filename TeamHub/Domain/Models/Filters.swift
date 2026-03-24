//
//  Filters.swift
//  TeamHub
//
//  Created by Ayush yadav on 24/03/26.
//

import Foundation

struct Filters {
    
    let designations: [String]
    let departments: [String]
    let statuses: [StatusFilter]
    let mobileTypes: [MobileType]
}

struct StatusFilter {
    let label: String
    let value: Bool
}
