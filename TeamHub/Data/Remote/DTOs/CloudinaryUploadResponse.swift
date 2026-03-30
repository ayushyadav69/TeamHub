//
//  CloudinaryUploadResponse.swift
//  TeamHub
//
//  Created by Ayush yadav on 27/03/26.
//

import Foundation

struct CloudinaryUploadResponse: Decodable {
    let secureUrl: String
    
    enum CodingKeys: String, CodingKey {
        case secureUrl = "secure_url"
    }
}

extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
