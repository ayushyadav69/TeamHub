//
//  RootView.swift
//  TeamHub
//
//  Created by Ayush yadav on 24/03/26.
//

import SwiftUI

struct RootView: View {
    
    let container: AppContainer
    
    var body: some View {
        EmployeeListView(fetchEmployeesUseCase: container.makeFetchEmployeesUseCase())
    }
}

//#Preview {
//    RootView()
//}
