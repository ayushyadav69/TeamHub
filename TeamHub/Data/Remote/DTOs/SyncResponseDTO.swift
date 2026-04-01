//
//  SyncResponseDTO.swift
//  TeamHub
//
//  Created by Ayush yadav on 01/04/26.
//

import Foundation

struct SyncResponseDTO: Decodable {
    let data: SyncDataDTO
    let success: Bool
}

struct SyncDataDTO: Decodable {
    let employees: [EmployeeDTO]
    let nextCursor: CursorDTO
    let hasMore: Bool
    
    enum CodingKeys: String, CodingKey {
        case employees
        case nextCursor = "next_cursor"
        case hasMore = "has_more"
    }
}

struct CursorDTO: Decodable {
    let seq: Int
}
