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
    func cityError(for city: String) -> String?
    func countryError(for country: String) -> String?
    func joiningDateError(for joiningDate: Date?) -> String?
    func mobileNumberError(for number: String) -> String?
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
    private static let namePattern = #"^[\p{L}](?:[\p{L} .'-]{0,48}[\p{L}])?$"#
    private static let emailPattern = #"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$"#
    private static let locationPattern = #"^[\p{L}](?:[\p{L} .'-]{0,48}[\p{L}])?$"#
    private static let mobilePattern = #"^\+?[0-9]{7,15}$"#

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
        validateRequiredText(
            name,
            pattern: Self.namePattern,
            requiredMessage: "Name is required",
            invalidMessage: "Use letters only, with spaces or . - '"
        )
    }

    func emailError(for email: String) -> String? {
        let trimmedEmail = trimmed(email)

        guard !trimmedEmail.isEmpty else {
            return "Email is required"
        }

        return matches(trimmedEmail, pattern: Self.emailPattern, options: [.regularExpression, .caseInsensitive])
            ? nil
            : "Enter a valid email address"
    }

    func cityError(for city: String) -> String? {
        validateRequiredText(
            city,
            pattern: Self.locationPattern,
            requiredMessage: "City is required",
            invalidMessage: "Use letters only, with spaces or . - '"
        )
    }

    func countryError(for country: String) -> String? {
        validateRequiredText(
            country,
            pattern: Self.locationPattern,
            requiredMessage: "Country is required",
            invalidMessage: "Use letters only, with spaces or . - '"
        )
    }
    
    func joiningDateError(for joiningDate: Date?) -> String? {
        joiningDate == nil ? "Joining date is required" : nil
    }

    func mobileNumberError(for number: String) -> String? {
        let trimmedNumber = trimmed(number)

        guard !trimmedNumber.isEmpty else {
            return "Phone number is required"
        }

        return matches(trimmedNumber, pattern: Self.mobilePattern)
            ? nil
            : "Enter 7 to 15 digits"
    }

    func isFormValid(_ input: EmployeeFormInput) -> Bool {
        nameError(for: input.name) == nil &&
        emailError(for: input.email) == nil &&
        cityError(for: input.city) == nil &&
        countryError(for: input.country) == nil &&
        joiningDateError(for: input.joiningDate) == nil &&
        input.mobiles.allSatisfy { mobileNumberError(for: $0.number) == nil } &&
        !trimmed(input.designation).isEmpty &&
        !trimmed(input.department).isEmpty
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
            mobiles: input.mobiles,
            syncStatus: SyncStatus.created.rawValue
        )

        return EmployeeFormData(
            employee: employee,
            imageData: imageData
        )
    }

    private func validateRequiredText(
        _ value: String,
        pattern: String,
        requiredMessage: String,
        invalidMessage: String
    ) -> String? {
        let trimmedValue = trimmed(value)

        guard !trimmedValue.isEmpty else {
            return requiredMessage
        }

        return matches(trimmedValue, pattern: pattern) ? nil : invalidMessage
    }

    private func trimmed(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func matches(
        _ value: String,
        pattern: String,
        options: String.CompareOptions = [.regularExpression]
    ) -> Bool {
        value.range(of: pattern, options: options) != nil
    }
}
