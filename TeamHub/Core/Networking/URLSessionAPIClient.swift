//
//  URLSessionAPIClient.swift
//  TeamHub
//
//  Created by Ayush yadav on 24/03/26.
//

import Foundation

final class URLSessionAPIClient: APIClient {
    
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func send<T: APIRequest>(_ request: T) async throws -> T.Response {
        
        let urlRequest = try request.buildURLRequest()
        print("🌐 Request URL:", urlRequest)
        
        let (data, response) = try await session.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard 200...299 ~= httpResponse.statusCode else {
            
            let message = try? JSONDecoder().decode(BaseResponseDTO.self, from: data).message
            
            throw APIError.invalidStatusCode(httpResponse.statusCode, message: message)
        }
        
        do {
            return try JSONDecoder().decode(T.Response.self, from: data)
        } catch {
            throw APIError.decodingError
        }
    }
}
