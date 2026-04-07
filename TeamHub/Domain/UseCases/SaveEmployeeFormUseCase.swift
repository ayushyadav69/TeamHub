//
//  SaveEmployeeFormUseCase.swift
//  TeamHub
//
//  Created by Codex on 07/04/26.
//

import Foundation

protocol SaveEmployeeFormUseCase {
    func execute(_ employeeForm: EmployeeFormData, isEdit: Bool) async throws
}

final class DefaultSaveEmployeeFormUseCase: SaveEmployeeFormUseCase {
    private let addEmployeeUseCase: AddEmployeeUseCase
    private let updateEmployeeUseCase: UpdateEmployeeUseCase

    init(
        addEmployeeUseCase: AddEmployeeUseCase,
        updateEmployeeUseCase: UpdateEmployeeUseCase
    ) {
        self.addEmployeeUseCase = addEmployeeUseCase
        self.updateEmployeeUseCase = updateEmployeeUseCase
    }

    func execute(_ employeeForm: EmployeeFormData, isEdit: Bool) async throws {
        if isEdit {
            try await updateEmployeeUseCase.execute(employeeForm)
        } else {
            try await addEmployeeUseCase.execute(employeeForm)
        }
    }
}
