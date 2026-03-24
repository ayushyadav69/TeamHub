//
//  FiltersResponseDTO.swift
//  TeamHub
//
//  Created by Ayush yadav on 24/03/26.
//

import Foundation

struct FiltersResponseDTO: Decodable {
    
    let status: String
    let message: String
    let data: FiltersDTO
}

struct FiltersDTO: Decodable {
    
    let designations: [String]
    let departments: [String]
    let statuses: [StatusDTO]
    let mobileTypes: [MobileTypeDTO]
}

struct StatusDTO: Decodable {
    let label: String
    let value: String
}

struct MobileTypeDTO: Decodable {
    let label: String
    let value: String
}
