//
//  APIClient.swift
//  TeamHub
//
//  Created by Ayush yadav on 24/03/26.
//

import Foundation

protocol APIClient {
    func send<T: APIRequest>(_ request: T) async throws -> T.Response
}
