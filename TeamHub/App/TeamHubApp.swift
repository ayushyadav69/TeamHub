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
    
    init() {
        container.setupNetworkSync()
        
        let cache = URLCache(
            memoryCapacity: 100 * 1024 * 1024, // 100 MB RAM
            diskCapacity: 500 * 1024 * 1024,   // 500 MB disk
            diskPath: "teamhub-image-caching"
        )

        URLCache.shared = cache
    }
    
    var body: some Scene {
        WindowGroup {
            RootView(container: container)
            
        }
    }
}
