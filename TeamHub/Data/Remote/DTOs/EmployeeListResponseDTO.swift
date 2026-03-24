//
//  EmployeeListResponseDTO.swift
//  TeamHub
//
//  Created by Ayush yadav on 24/03/26.
//

import Foundation

struct EmployeeListResponseDTO: Decodable {
    
    let status: String
    let message: String
    let data: [EmployeeDTO]
    let meta: MetaDTO
}
