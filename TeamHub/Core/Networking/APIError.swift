//
//  APIError.swift
//  TeamHub
//
//  Created by Ayush yadav on 24/03/26.
//

import Foundation

enum APIError: Error {
    
    case invalidResponse
    case invalidStatusCode(Int, message: String?)
    case decodingError
}

extension APIError {
    
    var isValidationError: Bool {
        switch self {
        case .invalidStatusCode(let code, _):
            return code == 400 || code == 409
        default:
            return false
        }
    }
    
    var message: String {
        switch self {
        case .invalidStatusCode(_, let message):
            return message ?? "Something went wrong"
        default:
            return "Something went wrong"
        }
    }
}
