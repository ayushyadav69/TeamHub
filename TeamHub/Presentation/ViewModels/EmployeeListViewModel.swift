//
//  EmployeeListViewModel.swift
//  TeamHub
//
//  Created by Ayush yadav on 24/03/26.
//

import Foundation
import Observation

@Observable
final class EmployeeListViewModel {
    
    private let fetchEmployeesUseCase: FetchEmployeesUseCase
    
    init(fetchEmployeesUseCase: FetchEmployeesUseCase) {
        self.fetchEmployeesUseCase = fetchEmployeesUseCase
    }
}
