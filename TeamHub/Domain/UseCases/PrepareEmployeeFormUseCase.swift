//
//  PrepareEmployeeFormUseCase.swift
//  TeamHub
//
//  Created by Codex on 07/04/26.
//

import Foundation

protocol PrepareEmployeeFormUseCase {
    func makeInput(from employee: EmployeeDetail?) -> EmployeeFormInput
    func nameError(for name: String) -> String?
    func emailError(for email: String) -> String?
    func isFormValid(_ input: EmployeeFormInput) -> Bool
    func canAddPhone(to mobiles: [Mobile]) -> Bool
    func addPhone(to mobiles: [Mobile], availableTypes: [MobileType]) -> [Mobile]
    func removePhone(id: String, from mobiles: [Mobile]) -> [Mobile]
    func isTypeUsed(_ type: MobileType, in mobiles: [Mobile], excluding id: String) -> Bool
    func normalizeFilters(
        _ filters: Filters,
        currentDesignation: String,
        currentDepartment: String
    ) -> EmployeeFormFilterOptions
    func makeFormData(
        from input: EmployeeFormInput,
        existingEmployee: EmployeeDetail?,
        imageData: Data?
    ) -> EmployeeFormData
}

final class DefaultPrepareEmployeeFormUseCase: PrepareEmployeeFormUseCase {
    func makeInput(from employee: EmployeeDetail?) -> EmployeeFormInput {
        EmployeeFormInput(
            selectedImageURL: employee?.imageURL,
            name: employee?.name ?? "",
            email: employee?.email ?? "",
            designation: employee?.designation ?? "",
            department: employee?.department ?? "",
            city: employee?.city ?? "",
            country: employee?.country ?? "",
            isActive: employee?.isActive ?? true,
            joiningDate: employee?.joiningDate,
            mobiles: employee?.mobiles ?? []
        )
    }

    func nameError(for name: String) -> String? {
        name.trimmingCharacters(in: .whitespaces).isEmpty ? "Name is required" : nil
    }

    func emailError(for email: String) -> String? {
        email.contains("@") ? nil : "Enter valid email"
    }

    func isFormValid(_ input: EmployeeFormInput) -> Bool {
        nameError(for: input.name) == nil &&
        emailError(for: input.email) == nil &&
        !input.designation.isEmpty &&
        !input.department.isEmpty
    }

    func canAddPhone(to mobiles: [Mobile]) -> Bool {
        mobiles.count < 3
    }

    func addPhone(to mobiles: [Mobile], availableTypes: [MobileType]) -> [Mobile] {
        guard canAddPhone(to: mobiles) else { return mobiles }

        let availableType = availableTypes.first { type in
            !mobiles.contains { $0.type == type }
        } ?? availableTypes.first ?? .home

        var updatedMobiles = mobiles
        updatedMobiles.append(
            Mobile(
                id: UUID().uuidString,
                type: availableType,
                number: ""
            )
        )

        return updatedMobiles
    }

    func removePhone(id: String, from mobiles: [Mobile]) -> [Mobile] {
        mobiles.filter { $0.id != id }
    }

    func isTypeUsed(_ type: MobileType, in mobiles: [Mobile], excluding id: String) -> Bool {
        mobiles.contains {
            $0.type == type && ($0.id ?? "") != id
        }
    }

    func normalizeFilters(
        _ filters: Filters,
        currentDesignation: String,
        currentDepartment: String
    ) -> EmployeeFormFilterOptions {
        let selectedDesignation = filters.designations.contains(currentDesignation)
            ? currentDesignation
            : (filters.designations.first ?? "")

        let selectedDepartment = filters.departments.contains(currentDepartment)
            ? currentDepartment
            : (filters.departments.first ?? "")

        return EmployeeFormFilterOptions(
            mobileTypes: filters.mobileTypes,
            designations: filters.designations,
            departments: filters.departments,
            selectedDesignation: selectedDesignation,
            selectedDepartment: selectedDepartment
        )
    }

    func makeFormData(
        from input: EmployeeFormInput,
        existingEmployee: EmployeeDetail?,
        imageData: Data?
    ) -> EmployeeFormData {
        let employee = EmployeeDetail(
            id: existingEmployee?.id ?? UUID().uuidString,
            name: input.name,
            email: input.email,
            designation: input.designation,
            department: input.department,
            city: input.city,
            country: input.country,
            isActive: input.isActive,
            imageURL: input.selectedImageURL,
            joiningDate: input.joiningDate,
            createdAt: existingEmployee?.createdAt,
            updatedAt: Date.now,
            deletedAt: existingEmployee?.deletedAt,
            mobiles: input.mobiles
        )

        return EmployeeFormData(
            employee: employee,
            imageData: imageData
        )
    }
}
