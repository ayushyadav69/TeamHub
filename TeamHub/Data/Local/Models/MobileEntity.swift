//
//  MobileEntity.swift
//  TeamHub
//
//  Created by Ayush yadav on 24/03/26.
//

import Foundation
import SwiftData

@Model
final class MobileEntity {
    
    var id: String?
    var type: String
    var number: String
    
    var employee: EmployeeEntity?   // inverse
    
    init(id: String?, type: String, number: String) {
        self.id = id
        self.type = type
        self.number = number
    }
}
