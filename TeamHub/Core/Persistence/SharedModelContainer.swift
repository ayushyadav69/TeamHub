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
        
        let config = ModelConfiguration(schema: schema)
        
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Failed to create container: \(error)")
        }
    }()
}
