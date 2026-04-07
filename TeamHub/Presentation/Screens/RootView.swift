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
                onNavigate: { route in
                    path.append(route)
                }
            )
            .navigationDestination(for: Route.self) { route in
                
                switch route {
                    
                case .detail(let id):
                    EmployeeDetailView(
                        container: container,
                        id: id,
                        onNavigate: { nextRoute in
                            path.append(nextRoute)
                        },
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
        .task {
            container.syncManager.startAutoSync()
        }
    }
}
