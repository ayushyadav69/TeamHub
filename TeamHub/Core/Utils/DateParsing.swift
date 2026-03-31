//
//  DateParsing.swift
//  TeamHub
//
//  Created by Ayush yadav on 24/03/26.
//

import Foundation

protocol DateParsing {
    func parse(_ string: String) -> Date?
}

final class DefaultDateParser: DateParsing {
    
    private let formatter: DateFormatter
    
    init() {
        formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
    }
    
    func parse(_ string: String) -> Date? {
        formatter.date(from: string)
    }
}

final class DefaultAPIDateParserISO: DateParsing {
    
    private let formatter = ISO8601DateFormatter()
    private let fallbackFormatter = ISO8601DateFormatter()
    
    init() {
        formatter.formatOptions = [.withInternetDateTime]
        fallbackFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    }
    
    func parse(_ string: String) -> Date? {
        guard !string.isEmpty else { return nil }
        
        return formatter.date(from: string)
        ?? fallbackFormatter.date(from: string)
    }
}
