//
//  DeleteEmployeeRequest.swift
//  TeamHub
//
//  Created by Ayush yadav on 24/03/26.
//

import Foundation

struct DeleteEmployeeRequest: APIRequest {
    
    typealias Response = BaseResponseDTO
    
    let id: String
    
//    var baseURL: String { baseURLString }
    var path: String { "/api/employees/\(id)" }
    var method: HTTPMethod { .DELETE }
    
    var queryItems: [URLQueryItem]? { nil }
    var headers: [String : String]? { nil }
    var body: Data? { nil }
}
