//
//  EmployeeDTO.swift
//  TeamHub
//
//  Created by Ayush yadav on 24/03/26.
//

import Foundation

struct EmployeeDTO: Decodable {
    
    let id: String
    let name: String
    let designation: String
    let department: String
    let isActive: Bool
    let imgURL: String
    let email: String
    let city: String
    let country: String
    let joiningDate: String
    let mobiles: [MobileDTO]?
    
    enum CodingKeys: String, CodingKey {
        case id, name, designation, department, email, city, country, mobiles
        case isActive = "is_active"
        case imgURL = "img_url"
        case joiningDate = "joining_date"
    }
}

struct MobileDTO: Decodable {
    let id: String?
    let type: String
    let number: String
}
