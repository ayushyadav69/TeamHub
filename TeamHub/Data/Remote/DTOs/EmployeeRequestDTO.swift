//
//  EmployeeRequestDTO.swift
//  TeamHub
//
//  Created by Ayush yadav on 24/03/26.
//

import Foundation

struct EmployeeRequestDTO: Encodable {
    
    let name: String
    let email: String
    let designation: String
    let department: String
    let city: String
    let country: String
    let is_active: Bool
    let img_url: String?
    let joining_date: String
    let mobiles: [MobileRequestDTO]
}

struct MobileRequestDTO: Encodable {
    let number: String
    let type: String
}
