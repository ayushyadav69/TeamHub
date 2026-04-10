//
//  EmployeeFormViewModel.swift
//  TeamHub
//
//  Created by Ayush yadav on 27/03/26.
//

import Foundation
import Observation

@MainActor
@Observable
final class EmployeeFormViewModel {
    
    // MARK: - Dependencies
    
    private let prepareEmployeeFormUseCase: PrepareEmployeeFormUseCase
    private let saveEmployeeFormUseCase: SaveEmployeeFormUseCase
    private let fetchFiltersUseCase: FetchFiltersUseCase
    
    // MARK: - Mode
    
    let isEdit: Bool
    private let existingEmployee: EmployeeDetail?
    var selectedImageData: Data?
    
    // MARK: - Form Fields
    
    var selectedImageURL: String?
    var name = ""
    var email = ""
    var designation = ""
    var department = ""
    var city = ""
    var country = ""
    var isActive = true
    var joiningDate: Date?
    
    var mobiles: [Mobile] = []
    var mobileTypes: [MobileType] = []
    var designations: [String] = []
    var departments: [String] = []
    
    // MARK: - UI State
    
    var isLoading = false
    var errorMessage: String?
    var shouldDismiss = false
    
    @ObservationIgnored
    private var retryAction: (@MainActor () async -> Void)?
    
    @ObservationIgnored
    private var initialFormInput: EmployeeFormInput
    
    private var deletedEmployeeObserverId: UUID?
    
    // MARK: - Init
    
    init(
        employee: EmployeeDetail?,
        prepareEmployeeFormUseCase: PrepareEmployeeFormUseCase,
        saveEmployeeFormUseCase: SaveEmployeeFormUseCase,
        fetchFiltersUseCase: FetchFiltersUseCase
    ) {
        self.existingEmployee = employee
        self.isEdit = employee != nil
        self.prepareEmployeeFormUseCase = prepareEmployeeFormUseCase
        self.saveEmployeeFormUseCase = saveEmployeeFormUseCase
        self.fetchFiltersUseCase = fetchFiltersUseCase

        let input = prepareEmployeeFormUseCase.makeInput(from: employee)
        self.initialFormInput = input

        selectedImageURL = input.selectedImageURL
        name = input.name
        email = input.email
        designation = input.designation
        department = input.department
        city = input.city
        country = input.country
        isActive = input.isActive
        mobiles = input.mobiles
        joiningDate = input.joiningDate
        
        if let employee {
            deletedEmployeeObserverId = DataChangeNotifier.shared
                .addDeletedEmployeeObserver { [weak self] deletedEmployeeId in
                    guard deletedEmployeeId == employee.id else { return }
                    
                    Task { @MainActor [weak self] in
                        self?.shouldDismiss = true
                    }
                }
        }
    }
    
    deinit {
        MainActor.assumeIsolated {
            if let deletedEmployeeObserverId {
                DataChangeNotifier.shared.removeObserver(deletedEmployeeObserverId)
            }
        }
    }
    
    var nameError: String? {
        prepareEmployeeFormUseCase.nameError(for: name)
    }

    var emailError: String? {
        prepareEmployeeFormUseCase.emailError(for: email)
    }
    
    var cityError: String? {
        prepareEmployeeFormUseCase.cityError(for: city)
    }
    
    var countryError: String? {
        prepareEmployeeFormUseCase.countryError(for: country)
    }
    
    var joiningDateError: String? {
        prepareEmployeeFormUseCase.joiningDateError(for: joiningDate)
    }

    var isFormValid: Bool {
        prepareEmployeeFormUseCase.isFormValid(formInput)
    }
    
    var hasChanges: Bool {
        selectedImageData != nil || formInput != initialFormInput
    }
    
    var canSave: Bool {
        isFormValid && !isLoading && (!isEdit || hasChanges)
    }

    var canAddPhone: Bool {
        prepareEmployeeFormUseCase.canAddPhone(to: mobiles)
    }

    private var formInput: EmployeeFormInput {
        EmployeeFormInput(
            selectedImageURL: selectedImageURL,
            name: name,
            email: email,
            designation: designation,
            department: department,
            city: city,
            country: country,
            isActive: isActive,
            joiningDate: joiningDate,
            mobiles: mobiles
        )
    }
    
    func addPhone() {
        mobiles = prepareEmployeeFormUseCase.addPhone(
            to: mobiles,
            availableTypes: mobileTypes
        )
    }

    func removePhone(id: String) {
        mobiles = prepareEmployeeFormUseCase.removePhone(
            id: id,
            from: mobiles
        )
    }
    
    func loadFilters() async {
        do {
            let filters = try await fetchFiltersUseCase.forForm()

            let normalizedFilters = prepareEmployeeFormUseCase.normalizeFilters(
                filters,
                currentDesignation: designation,
                currentDepartment: department
            )

            mobileTypes = normalizedFilters.mobileTypes
            designations = normalizedFilters.designations
            departments = normalizedFilters.departments
            designation = normalizedFilters.selectedDesignation
            department = normalizedFilters.selectedDepartment
            
            if isEdit {
                initialFormInput = makeInitialFormInput(
                    designation: normalizedFilters.selectedDesignation,
                    department: normalizedFilters.selectedDepartment
                )
            }
            
        } catch {
            presentError(
                error,
                fallback: "Failed to load form options",
                retryAction: { [weak self] in
                    await self?.loadFilters()
                }
            )
        }
    }
    
    func isTypeUsed(_ type: MobileType, excluding id: String) -> Bool {
        prepareEmployeeFormUseCase.isTypeUsed(
            type,
            in: mobiles,
            excluding: id
        )
    }
    
    func mobileNumberError(for number: String) -> String? {
        prepareEmployeeFormUseCase.mobileNumberError(for: number)
    }
    
    func submit() async -> Bool {
        
        guard isFormValid else {
            errorMessage = "Please fix the highlighted fields"
            retryAction = nil
            return false
        }
        
        isLoading = true
        defer { isLoading = false }
        errorMessage = nil
        
        do {
            let employeeForm = prepareEmployeeFormUseCase.makeFormData(
                from: formInput,
                existingEmployee: existingEmployee,
                imageData: selectedImageData
            )

            try await saveEmployeeFormUseCase.execute(
                employeeForm,
                isEdit: isEdit
            )
            
            return true
            
        } catch {
            presentError(error, fallback: "Failed to save")
            return false
        }
    }
    
    var canRetryError: Bool {
        retryAction != nil
    }
    
    func dismissError() {
        errorMessage = nil
        retryAction = nil
    }
    
    func retryLastError() {
        guard let retryAction else {
            dismissError()
            return
        }
        
        dismissError()
        
        Task {
            await retryAction()
        }
    }
    
    private func presentError(
        _ error: Error,
        fallback: String,
        retryAction: (@MainActor () async -> Void)? = nil
    ) {
        errorMessage = error.userMessage(fallback: fallback)
        self.retryAction = retryAction
    }
    
    private func makeInitialFormInput(
        designation: String? = nil,
        department: String? = nil
    ) -> EmployeeFormInput {
        var input = prepareEmployeeFormUseCase.makeInput(from: existingEmployee)
        input.designation = designation ?? input.designation
        input.department = department ?? input.department
        return input
    }
}
