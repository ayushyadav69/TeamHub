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
                destination(for: route)
            }
        }
    }
}

private extension RootView {
    
    func handleRoute(_ route: Route) {
        path.append(route)
    }
    
    @ViewBuilder
    func destination(for route: Route) -> some View {
        
        switch route {
            
        case .detail(let id):
            Text("Detail Screen for \(id)")
            
        case .add:
            Text("Add Employee")
            
        case .edit(let employee):
            Text("Edit \(employee.name)")
        }
    }
}

//#Preview {
//    RootView()
//}
