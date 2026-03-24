//
//  EmployeeListView.swift
//  TeamHub
//
//  Created by Ayush yadav on 24/03/26.
//

import SwiftUI

struct EmployeeListView: View {
    
    @State private var viewModel: EmployeeListViewModel
    
    init(fetchEmployeesUseCase: FetchEmployeesUseCase) {
        _viewModel = State(
            wrappedValue: EmployeeListViewModel(
                fetchEmployeesUseCase: fetchEmployeesUseCase
            )
        )
    }
    
    var body: some View {
        Text("Employee List")
    }
}
