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
    
    private let createEmployeeUseCase: AddEmployeeUseCase
    private let updateEmployeeUseCase: UpdateEmployeeUseCase
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
    var joiningDate: Date = Date.now
    
    var mobiles: [Mobile] = []
    var mobileTypes: [MobileType] = []
    var designations: [String] = []
    var departments: [String] = []
    
    // MARK: - UI State
    
    var isLoading = false
    var errorMessage: String?
    
    // MARK: - Init
    
    init(
        employee: EmployeeDetail?,
        createEmployeeUseCase: AddEmployeeUseCase,
        updateEmployeeUseCase: UpdateEmployeeUseCase,
        fetchFiltersUseCase: FetchFiltersUseCase
    ) {
        self.existingEmployee = employee
        self.isEdit = employee != nil
        self.createEmployeeUseCase = createEmployeeUseCase
        self.updateEmployeeUseCase = updateEmployeeUseCase
        self.fetchFiltersUseCase = fetchFiltersUseCase
        
        if let employee {
            populate(employee)
        }
    }
    
    private func populate(_ employee: EmployeeDetail) {
        
        selectedImageURL = employee.imageURL
        name = employee.name
        email = employee.email
        designation = employee.designation
        department = employee.department
        city = employee.city
        country = employee.country
        isActive = employee.isActive
        mobiles = employee.mobiles
        joiningDate = employee.joiningDate
    }
    
    var nameError: String? {
        name.trimmingCharacters(in: .whitespaces).isEmpty ? "Name is required" : nil
    }

    var emailError: String? {
        email.contains("@") ? nil : "Enter valid email"
    }

    var isFormValid: Bool {
        nameError == nil &&
        emailError == nil &&
        !designation.isEmpty &&
        !department.isEmpty
    }
    
    func addPhone() {
        guard mobiles.count < 3 else { return }
        
        let availableType = mobileTypes.first { type in
            !mobiles.contains { $0.type == type }
        } ?? mobileTypes.first ?? .home
        
        mobiles.append(
            Mobile(
                id: UUID().uuidString,
                type: availableType,
                number: ""
            )
        )
    }

    func removePhone(id: String) {
        mobiles.removeAll { $0.id == id }
    }
    
    func loadFilters() async {
        do {
            let filters = try await fetchFiltersUseCase.forForm()
            
            mobileTypes = filters.mobileTypes
            designations = filters.designations
            departments = filters.departments
            
            // FIX HERE
            if !designations.contains(designation) {
                designation = designations.first ?? ""
            }

            if !departments.contains(department) {
                department = departments.first ?? ""
            }
            
        } catch {
            print("Failed to load filters:", error)
        }
    }
    
    func isTypeUsed(_ type: MobileType, excluding id: String) -> Bool {
        mobiles.contains {
            $0.type == type && $0.id != id
        }
    }
    
    func submit() async -> Bool {
        
        guard isFormValid else {
            errorMessage = "Please fill all required fields"
            return false
        }
        
        isLoading = true
        defer { isLoading = false }
        errorMessage = nil
        
        do {
            
            let employee = EmployeeDetail(
                id: existingEmployee?.id ?? UUID().uuidString,
                name: name,
                email: email,
                designation: designation,
                department: department,
                city: city,
                country: country,
                isActive: isActive,
                imageURL: selectedImageURL,
                joiningDate: joiningDate,
                createdAt: existingEmployee?.createdAt,
                updatedAt: Date.now,
                deletedAt: existingEmployee?.deletedAt,
                mobiles: mobiles
            )
            
            let form = EmployeeFormData(employee: employee, imageData: selectedImageData)
            
            if isEdit {
                try await updateEmployeeUseCase.execute(form)
            } else {
                try await createEmployeeUseCase.execute(form)
            }
            
            return true
            
        } catch {
            errorMessage = (error as? APIError)?.message ?? "Failed to save"
            return false
        }
        
//        isLoading = false
    }
}
