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
    
    private let lock = NSLock()
    private var observers: [UUID: () -> Void] = [:]
    private var deletedEmployeeObservers: [UUID: (String) -> Void] = [:]
    private var syncErrorObservers: [UUID: (String) -> Void] = [:]
    
    func addObserver(_ callback: @escaping () -> Void) -> UUID {
        let id = UUID()
        lock.lock()
        observers[id] = callback
        lock.unlock()
        return id
    }
    
    func addDeletedEmployeeObserver(
        _ callback: @escaping (String) -> Void
    ) -> UUID {
        let id = UUID()
        lock.lock()
        deletedEmployeeObservers[id] = callback
        lock.unlock()
        return id
    }
    
    func addSyncErrorObserver(
        _ callback: @escaping (String) -> Void
    ) -> UUID {
        let id = UUID()
        lock.lock()
        syncErrorObservers[id] = callback
        lock.unlock()
        return id
    }
    
    func removeObserver(_ id: UUID) {
        lock.lock()
        observers.removeValue(forKey: id)
        deletedEmployeeObservers.removeValue(forKey: id)
        syncErrorObservers.removeValue(forKey: id)
        lock.unlock()
    }
    
    func notify() {
        lock.lock()
        let callbacks = Array(observers.values)
        lock.unlock()
        
        callbacks.forEach { $0() }
    }
    
    func notifyEmployeeDeleted(id: String) {
        lock.lock()
        let callbacks = Array(deletedEmployeeObservers.values)
        lock.unlock()
        
        callbacks.forEach { $0(id) }
    }
    
    func notifySyncError(message: String) {
        lock.lock()
        let callbacks = Array(syncErrorObservers.values)
        lock.unlock()
        
        callbacks.forEach { $0(message) }
    }
}
