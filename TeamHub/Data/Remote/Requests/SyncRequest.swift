//
//  SyncRequest.swift
//  TeamHub
//
//  Created by Ayush yadav on 01/04/26.
//

import Foundation

struct SyncRequest: APIRequest {
    
    typealias Response = SyncResponseDTO
    
    let cursor: Int
    
    var method: HTTPMethod {
        .POST
    }
    
    var path: String {
        "/api/sync"
    }
    
    var queryItems: [URLQueryItem]? {
        nil
    }
    
    var headers: [String: String]? {
        [
            "Content-Type": "application/json"
        ]
    }
    
    var body: Data? {
        try? JSONEncoder().encode(
            CursorBody(cursor: Cursor(seq: cursor))
        )
    }
}
private struct CursorBody: Encodable {
    let cursor: Cursor
}

private struct Cursor: Encodable {
    let seq: Int
}


