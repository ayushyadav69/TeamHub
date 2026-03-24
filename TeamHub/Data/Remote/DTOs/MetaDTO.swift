//
//  MetaDTO.swift
//  TeamHub
//
//  Created by Ayush yadav on 24/03/26.
//

import Foundation

struct MetaDTO: Decodable {
    
    let totalCount: Int
    let page: Int
    let pageSize: Int
    let hasNextPage: Bool
    
    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case page
        case pageSize = "page_size"
        case hasNextPage = "has_next_page"
    }
}
