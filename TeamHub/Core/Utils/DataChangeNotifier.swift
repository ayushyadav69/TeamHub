//
//  DataChangeNotifier.swift
//  TeamHub
//
//  Created by Ayush yadav on 01/04/26.
//

import Foundation

final class DataChangeNotifier {
    
    static let shared = DataChangeNotifier()
    
    private init() {}
    
    private var observers: [UUID: () -> Void] = [:]
    
    func addObserver(_ callback: @escaping () -> Void) -> UUID {
        let id = UUID()
        observers[id] = callback
        return id
    }
    
    func removeObserver(_ id: UUID) {
        observers.removeValue(forKey: id)
    }
    
    func notify() {
        observers.values.forEach { $0() }
    }
}
