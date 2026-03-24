//
//  CreateEmployeeRequest.swift
//  TeamHub
//
//  Created by Ayush yadav on 24/03/26.
//

import Foundation

struct CreateEmployeeRequest: APIRequest {
    
    typealias Response = CreateEmployeeResponseDTO
    
    let dto: EmployeeRequestDTO
    
//    var baseURL: String { baseURLString }
    var path: String { "/api/employees" }
    var method: HTTPMethod { .POST }
    
    var queryItems: [URLQueryItem]? { nil }
    
    var headers: [String : String]? {
        ["Content-Type": "application/json"]
    }
    
    var body: Data? {
        try? JSONEncoder().encode(dto)
    }
}
