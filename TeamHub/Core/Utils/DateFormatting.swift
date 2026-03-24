//
//  DateFormatting.swift
//  TeamHub
//
//  Created by Ayush yadav on 24/03/26.
//

import Foundation

protocol DateFormatting {
    func string(from date: Date) -> String
}

final class DefaultAPIDateFormatter: DateFormatting {
    
    private let formatter: DateFormatter
    
    init() {
        formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
    }
    
    func string(from date: Date) -> String {
        formatter.string(from: date)
    }
}
