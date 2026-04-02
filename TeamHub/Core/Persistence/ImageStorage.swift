//
//  ImageStorage.swift
//  TeamHub
//
//  Created by Ayush yadav on 02/04/26.
//

import Foundation

final class ImageStorage {
    
    static func save(_ data: Data) -> String {
        let fileName = UUID().uuidString + ".jpg"
        
        let url = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(fileName)
        
        try? data.write(to: url)
        
        return url.path
    }
    
    static func load(path: String) -> Data? {
        return FileManager.default.contents(atPath: path)
    }
}
