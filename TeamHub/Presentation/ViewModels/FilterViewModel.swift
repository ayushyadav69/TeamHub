//
//  FilterViewModel.swift
//  TeamHub
//
//  Created by Codex on 07/04/26.
//

import Foundation
import Observation

@MainActor
@Observable
final class FilterViewModel {
    let availableDesignations: [String]
    let availableDepartments: [String]

    var selectedStatus: Bool?

    private var selectedDesignationSet: Set<String>
    private var selectedDepartmentSet: Set<String>

    init(
        initialStatus: Bool?,
        initialDesignations: [String],
        initialDepartments: [String],
        availableDesignations: [String],
        availableDepartments: [String]
    ) {
        self.selectedStatus = initialStatus
        self.availableDesignations = availableDesignations
        self.availableDepartments = availableDepartments
        self.selectedDesignationSet = Set(initialDesignations)
        self.selectedDepartmentSet = Set(initialDepartments)
    }

    var selectedDesignations: [String] {
        availableDesignations.filter(selectedDesignationSet.contains)
    }

    var selectedDepartments: [String] {
        availableDepartments.filter(selectedDepartmentSet.contains)
    }

    func isDesignationSelected(_ value: String) -> Bool {
        selectedDesignationSet.contains(value)
    }

    func isDepartmentSelected(_ value: String) -> Bool {
        selectedDepartmentSet.contains(value)
    }

    func toggleDesignation(_ value: String) {
        if selectedDesignationSet.contains(value) {
            selectedDesignationSet.remove(value)
        } else {
            selectedDesignationSet.insert(value)
        }
    }

    func toggleDepartment(_ value: String) {
        if selectedDepartmentSet.contains(value) {
            selectedDepartmentSet.remove(value)
        } else {
            selectedDepartmentSet.insert(value)
        }
    }

    func toggleStatus(_ value: Bool) {
        selectedStatus = selectedStatus == value ? nil : value
    }

    func reset() {
        selectedStatus = nil
        selectedDesignationSet.removeAll()
        selectedDepartmentSet.removeAll()
    }
}
