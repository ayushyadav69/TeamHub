//
//  TeamHubApp.swift
//  TeamHub
//
//  Created by Ayush yadav on 24/03/26.
//

import SwiftUI

@main
struct TeamHubApp: App {
    
    private let container = AppContainer()
    
    var body: some Scene {
        WindowGroup {
            RootView(container: container)
            
        }
    }
}
