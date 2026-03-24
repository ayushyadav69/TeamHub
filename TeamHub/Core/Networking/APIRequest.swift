//
//  APIRequest.swift
//  TeamHub
//
//  Created by Ayush yadav on 24/03/26.
//

import Foundation

protocol APIRequest {
    
    associatedtype Response: Decodable
    
//    var baseURL: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    
    var queryItems: [URLQueryItem]? { get }
    var headers: [String: String]? { get }
    var body: Data? { get }
}

extension APIRequest {
    
    func buildURLRequest() throws -> URLRequest {
        
        guard var components = URLComponents(string: baseURL + path) else {
            throw APIError.invalidResponse
        }
        
        components.queryItems = queryItems
        
        guard let url = components.url else {
            throw APIError.invalidResponse
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.httpBody = body
        
        headers?.forEach {
            request.addValue($0.value, forHTTPHeaderField: $0.key)
        }
        
        return request
    }
}

extension APIRequest {
    
    var baseURL: String {
        "https://employee-static-api.onrender.com"
    }
}
