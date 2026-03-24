//
//  FetchEmployeesRequest.swift
//  TeamHub
//
//  Created by Ayush yadav on 24/03/26.
//

import Foundation

struct FetchEmployeesRequest: APIRequest {
    
    typealias Response = EmployeeListResponseDTO
    
    let query: SearchFilterQuery?
    let page: EmployeePage
    
//    var baseURL: String {
//        "https://employee-static-api.onrender.com"
//    }
    
    var path: String {
        "/api/employees"
    }
    
    var method: HTTPMethod {
        .GET
    }
    
    var queryItems: [URLQueryItem]? {
        
        var items: [URLQueryItem] = [
            URLQueryItem(name: "limit", value: "\(page.pageSize)"),
            URLQueryItem(name: "offset", value: "\(page.offset)")
        ]
        
        if let query {
            items.append(contentsOf: query.toQueryItems())
        }
        
        return items
    }
    
    var headers: [String : String]? { nil }
    var body: Data? { nil }
}
