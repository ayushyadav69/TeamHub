//
//  DefaultNetworkMonitor.swift
//  TeamHub
//
//  Created by Ayush yadav on 24/03/26.
//

import Foundation
import Network

final class DefaultNetworkMonitor: NetworkMonitor {
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    private(set) var isConnected: Bool = true
    
    init() {
        startMonitoring()
    }
    
    private func startMonitoring() {
        
        monitor.pathUpdateHandler = { [weak self] path in
            self?.isConnected = path.status == .satisfied
        }
        
        monitor.start(queue: queue)
    }
}
