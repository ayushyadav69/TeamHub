//
//  CursorStore.swift
//  TeamHub
//
//  Created by Ayush yadav on 01/04/26.
//

import Foundation

final class CursorStore {
    
    private let key = "sync_cursor"
    
    func save(_ seq: Int) {
        UserDefaults.standard.set(seq, forKey: key)
    }
    
    func get() -> Int? {
        UserDefaults.standard.integer(forKey: key) == 0
        ? nil
        : UserDefaults.standard.integer(forKey: key)
    }
}
