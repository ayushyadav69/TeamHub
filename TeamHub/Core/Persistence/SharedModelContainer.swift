//
//  SharedModelContainer.swift
//  TeamHub
//
//  Created by Ayush yadav on 24/03/26.
//

import Foundation
import SwiftData

enum SharedModelContainer {
    
    static let container: ModelContainer = {
        
        let schema = Schema([
            EmployeeEntity.self,
            MobileEntity.self
        ])
        
        // STEP 1: Get Application Support directory
        let appSupportURL = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first!
        
        // STEP 2: Create directory (THIS WAS MISSING)
        do {
            try FileManager.default.createDirectory(
                at: appSupportURL,
                withIntermediateDirectories: true
            )
        } catch {
            fatalError("Failed to create directory: \(error)")
        }
        
        // STEP 3: Provide explicit URL to SwiftData
        let storeURL = appSupportURL.appendingPathComponent("default.store")
        
        let config = ModelConfiguration(
            schema: schema,
            url: storeURL // IMPORTANT
        )
        
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Failed to create container: \(error)")
        }
    }()
}
