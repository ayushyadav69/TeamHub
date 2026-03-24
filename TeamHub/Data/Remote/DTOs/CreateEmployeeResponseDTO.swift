//
//  CreateEmployeeResponseDTO.swift
//  TeamHub
//
//  Created by Ayush yadav on 24/03/26.
//

import Foundation

struct CreateEmployeeResponseDTO: Decodable {
    
    let status: String
    let message: String
    let data: CreatedEmployeeDTO
}

struct CreatedEmployeeDTO: Decodable {
    let id: String
}
