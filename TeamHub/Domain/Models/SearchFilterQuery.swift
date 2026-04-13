//
//  SearchFilterQuery.swift
//  TeamHub
//
//  Created by Ayush yadav on 24/03/26.
//

import Foundation

struct SearchFilterQuery: Equatable {
    
    let searchText: String?
    let designations: [String]
    let departments: [String] 
    let isActive: Bool?
}

extension SearchFilterQuery {
    
    func toQueryItems() -> [URLQueryItem] {
        
        var items: [URLQueryItem] = []
        
        if let searchText {
            items.append(URLQueryItem(name: "search", value: searchText))
        }
        
        if !designations.isEmpty {
            items.append(
                URLQueryItem(
                    name: "designation",
                    value: designations.joined(separator: ",")
                )
            )
        }
        
        if !departments.isEmpty {
            items.append(
                URLQueryItem(
                    name: "department",
                    value: departments.joined(separator: ",")
                )
            )
        }
        
        if let isActive {
            items.append(
                URLQueryItem(
                    name: "status",
                    value: isActive ? "active" : "inactive"
                )
            )
        }
        
        return items
    }
}
