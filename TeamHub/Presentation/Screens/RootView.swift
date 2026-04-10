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
    @State private var syncErrorMessage: String?
    @State private var syncErrorObserverId: UUID?
    
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
                        },
                        onDeletedDismiss: {
                            path.removeAll { route in
                                switch route {
                                case .detail(let routeId):
                                    routeId == id
                                case .edit(let employee):
                                    employee.id == id
                                default:
                                    false
                                }
                            }
                        }
                    )
                    
                case .add:
                    EmployeeFormView(
                        container: container,
                        employee: nil,
                        onDismiss: { path.removeLast() },
                        onDeletedDismiss: { path.removeLast() }
                    )
                    
                case .edit(let employee):
                    EmployeeFormView(
                        container: container,
                        employee: employee,
                        onDismiss: { path.removeLast() },
                        onDeletedDismiss: {
                            path.removeAll { route in
                                switch route {
                                case .detail(let routeId):
                                    routeId == employee.id
                                case .edit(let routeEmployee):
                                    routeEmployee.id == employee.id
                                default:
                                    false
                                }
                            }
                        }
                    )
                }
            }
        }
        .alert("Sync Error", isPresented: syncErrorAlertIsPresented) {
            Button("Refresh") {
                refreshFromServer()
            }
            
            Button("Not Now", role: .cancel) {
                syncErrorMessage = nil
            }
        } message: {
            Text(syncErrorMessage ?? "")
        }
        .task {
            if syncErrorObserverId == nil {
                syncErrorObserverId = DataChangeNotifier.shared.addSyncErrorObserver { message in
                    Task { @MainActor in
                        syncErrorMessage = message
                    }
                }
            }
            
            container.syncManager.startAutoSync()
        }
        .onDisappear {
            if let syncErrorObserverId {
                DataChangeNotifier.shared.removeObserver(syncErrorObserverId)
                self.syncErrorObserverId = nil
            }
        }
    }
    
    private var syncErrorAlertIsPresented: Binding<Bool> {
        Binding(
            get: { syncErrorMessage != nil },
            set: { isPresented in
                if !isPresented {
                    syncErrorMessage = nil
                }
            }
        )
    }
    
    private func refreshFromServer() {
        syncErrorMessage = nil
        
        Task {
            do {
                try await container.makeRefreshServerDataUseCase().execute()
                
                await MainActor.run {
                    path.removeAll()
                }
                
                DataChangeNotifier.shared.notify()
            } catch {
                await MainActor.run {
                    syncErrorMessage = error.userMessage(
                        fallback: "We couldn't refresh from the server."
                    )
                }
            }
        }
    }
}
