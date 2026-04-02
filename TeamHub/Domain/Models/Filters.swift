//
//  Filters.swift
//  TeamHub
//
//  Created by Ayush yadav on 24/03/26.
//

import Foundation

struct Filters: Codable {
    
    let designations: [String]
    let departments: [String]
    let statuses: [StatusFilter]
    let mobileTypes: [MobileType]
}

struct StatusFilter: Codable {
    let label: String
    let value: Bool
}
