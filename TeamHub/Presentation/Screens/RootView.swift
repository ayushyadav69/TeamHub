//
//  RootView.swift
//  TeamHub
//
//  Created by Ayush yadav on 24/03/26.
//

import SwiftUI

struct RootView: View {
    
    let container: AppContainer
    
    @State private var path: [Route] = []
    
    var body: some View {
        
        NavigationStack(path: $path) {
            
            EmployeeListView(
                container: container,
                onNavigate: handleRoute
            )
            .navigationDestination(for: Route.self) { route in
                
                switch route {
                    
                case .detail(let id):
                    EmployeeDetailView(
                        container: container,
                        id: id,
                        onNavigate: handleRoute,
                        onDismiss: {
                            path.removeLast()
                        }
                    )
                    
                case .add:
                    EmployeeFormView(
                            container: container,
                            employee: nil,
                            onDismiss: { path.removeLast() }
                        )
                    
                case .edit(let employee):
                    EmployeeFormView(
                        container: container,
                        employee: employee,
                        onDismiss: { path.removeLast() }
                    )
                }
            }
        }
    }
}

private extension RootView {
    
    func handleRoute(_ route: Route) {
        print("Navigating to:", route)
        path.append(route)
    }
    
//    @ViewBuilder
//    func destination(for route: Route) -> some View {
//        
//        switch route {
//            
//        case .detail(let id):
//            EmployeeDetailView(container: container, id: id)
//            
//        case .add:
//            Text("Add Employee")
//            
//        case .edit(let employee):
//            Text("Edit \(employee.name)")
//        }
//    }
}

//#Preview {
//    RootView()
//}
