//
//  EmployeeListFilters.swift
//  TeamHub
//
//  Created by Codex on 07/04/26.
//

import Foundation

struct EmployeeListFilters: Equatable {
    var searchText: String = ""
    var selectedStatus: Bool? = nil
    var selectedDesignations: [String] = []
    var selectedDepartments: [String] = []
}
