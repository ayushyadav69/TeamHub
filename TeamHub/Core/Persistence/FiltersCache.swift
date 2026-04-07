//
//  FiltersCache.swift
//  TeamHub
//
//  Created by Ayush yadav on 02/04/26.
//

import Foundation

final class FiltersCache {
    
    private let key = "cached_filters"
    
    func save(_ filters: Filters) {
        do {
            let data = try JSONEncoder().encode(filters)
            UserDefaults.standard.set(data, forKey: key)
        } catch {
            print("Failed to cache filters:", error)
        }
    }
    
    func load() -> Filters? {
        guard let data = UserDefaults.standard.data(forKey: key) else {
            return nil
        }
        
        do {
            return try JSONDecoder().decode(Filters.self, from: data)
        } catch {
            print("Failed to decode cached filters:", error)
            return nil
        }
    }
}
