//
//  ManageEmployeeListFiltersUseCase.swift
//  TeamHub
//
//  Created by Codex on 07/04/26.
//

import Foundation

protocol ManageEmployeeListFiltersUseCase {
    func buildQuery(from filters: EmployeeListFilters) -> SearchFilterQuery?
    func activeFilterCount(for filters: EmployeeListFilters) -> Int
}

final class DefaultManageEmployeeListFiltersUseCase: ManageEmployeeListFiltersUseCase {
    func buildQuery(from filters: EmployeeListFilters) -> SearchFilterQuery? {
        let trimmedSearchText = filters.searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        let hasSearch = !trimmedSearchText.isEmpty
        let hasStatus = filters.selectedStatus != nil
        let hasDesignations = !filters.selectedDesignations.isEmpty
        let hasDepartments = !filters.selectedDepartments.isEmpty

        guard hasSearch || hasStatus || hasDesignations || hasDepartments else {
            return nil
        }

        return SearchFilterQuery(
            searchText: hasSearch ? trimmedSearchText : nil,
            designations: filters.selectedDesignations,
            departments: filters.selectedDepartments,
            isActive: filters.selectedStatus
        )
    }

    func activeFilterCount(for filters: EmployeeListFilters) -> Int {
        var count = 0

        if filters.selectedStatus != nil {
            count += 1
        }

        if !filters.selectedDesignations.isEmpty {
            count += 1
        }

        if !filters.selectedDepartments.isEmpty {
            count += 1
        }

        return count
    }
}
