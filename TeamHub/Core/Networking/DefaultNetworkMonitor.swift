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
    
    private(set) var isConnected: Bool = false
    
    var onReconnect: (() -> Void)? //  ADD THIS
    
    init() {
        startMonitoring()
    }
    
    private func startMonitoring() {
        
        monitor.pathUpdateHandler = { [weak self] path in
            
            guard let self else { return }
            
            let wasConnected = self.isConnected
            let nowConnected = path.status == .satisfied
            
            self.isConnected = nowConnected
            
            //  Detect reconnect
            if !wasConnected && nowConnected {
                DispatchQueue.main.async {
                    self.onReconnect?()
                }
            }
        }
        
        monitor.start(queue: queue)
    }
}
