//
//  DateParsing.swift
//  TeamHub
//
//  Created by Ayush yadav on 24/03/26.
//

import Foundation

protocol DateParsing {
    func parse(_ string: String) -> Date
}

final class DefaultDateParser: DateParsing {
    
    private let formatter: DateFormatter
    
    init() {
        formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
    }
    
    func parse(_ string: String) -> Date {
        formatter.date(from: string) ?? Date()
    }
}
