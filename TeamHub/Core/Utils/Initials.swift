//
//  Initials.swift
//  TeamHub
//
//  Created by Ayush yadav on 07/04/26.
//

import Foundation

extension String {
    
    var initials: String {
        let parts = self
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .split(separator: " ")
        
        let letters = parts.prefix(2).compactMap { $0.first }
        
        return letters.map { String($0).uppercased() }.joined()
    }
}
