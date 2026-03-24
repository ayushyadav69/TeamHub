//
//  UpdateEmployeeRequest.swift
//  TeamHub
//
//  Created by Ayush yadav on 24/03/26.
//

import Foundation

struct UpdateEmployeeRequest: APIRequest {
    
    typealias Response = BaseResponseDTO
    
    let id: String
    let dto: EmployeeRequestDTO
    
//    var baseURL: String { baseURLString }
    
    var path: String {
        "/api/employees/\(id)"
    }
    
    var method: HTTPMethod { .PATCH }
    
    var queryItems: [URLQueryItem]? { nil }
    
    var headers: [String : String]? {
        ["Content-Type": "application/json"]
    }
    
    var body: Data? {
        try? JSONEncoder().encode(dto)
    }
}
