//
//  FetchEmployeeDetailRequest.swift
//  TeamHub
//
//  Created by Ayush yadav on 24/03/26.
//

import Foundation

struct FetchEmployeeDetailRequest: APIRequest {
    
    typealias Response = EmployeeDetailResponseDTO
    
    let id: String
    
//    var baseURL: String {
//        "https://employee-static-api.onrender.com"
//    }
    
    var path: String {
        "/api/employees/\(id)"
    }
    
    var method: HTTPMethod {
        .GET
    }
    
    var queryItems: [URLQueryItem]? { nil }
    
    var headers: [String : String]? { nil }
    
    var body: Data? { nil }
}
