//
//  FetchFiltersRequest.swift
//  TeamHub
//
//  Created by Ayush yadav on 24/03/26.
//

import Foundation

struct FetchFiltersRequest: APIRequest {
    
    typealias Response = FiltersResponseDTO
    
//    var baseURL: String { baseURLString }
    var path: String { "/api/employees/filters" }
    var method: HTTPMethod { .GET }
    
    var queryItems: [URLQueryItem]? { nil }
    var headers: [String : String]? { nil }
    var body: Data? { nil }
}
