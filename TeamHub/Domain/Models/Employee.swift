//
//  Employee.swift
//  TeamHub
//
//  Created by Ayush yadav on 24/03/26.
//

import Foundation

struct Employee: Identifiable {
    
    let id: String
    let name: String
    let designation: String
    let department: String
    let isActive: Bool
    let imageURL: String?
    var imageLocalPath: String?
}
