//
//  EmployeeDetailResponseDTO.swift
//  TeamHub
//
//  Created by Ayush yadav on 24/03/26.
//

import Foundation

struct EmployeeDetailResponseDTO: Decodable {
    
    let status: String
    let message: String
    let data: EmployeeDTO
}
