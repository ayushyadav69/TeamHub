//
//  BaseResponseDTO.swift
//  TeamHub
//
//  Created by Ayush yadav on 24/03/26.
//

import Foundation

struct BaseResponseDTO: Decodable {
    let status: String
    let message: String
}
