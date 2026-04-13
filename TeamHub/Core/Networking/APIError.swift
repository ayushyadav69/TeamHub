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
    case custom(String)
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
        case .invalidResponse:
            return "We received an invalid response from the server."
        case .decodingError:
            return "We couldn't read the server response."
        case .custom(let message):
            return message
        case .invalidStatusCode(_, let message):
            
//            return message ?? "Something went wrong"
            guard let message else { return "Something went wrong."}
            
            if message.contains("employees_email_key") {
                return "Error: Email exists"
            } else if message.contains("unique_home_number") {
                return "Error: Home phone number should be unique."
            } else {
                return message
            }
        }
    }
}

extension Error {
    
    func userMessage(fallback: String = "Something went wrong") -> String {
        if let apiError = self as? APIError {
            return apiError.message
        }
        
//        if let urlError = self as? URLError {
//            switch urlError.code {
//            case .notConnectedToInternet, .networkConnectionLost:
//                return "You're offline. Please check your internet connection and try again."
//            case .timedOut:
//                return "The request timed out. Please try again."
//            case .cannotFindHost, .cannotConnectToHost:
//                return "We couldn't reach the server right now. Please try again."
//            default:
//                break
//            }
//        }
        
        return fallback
    }
}
