//
//  NetworkMonitor.swift
//  TeamHub
//
//  Created by Ayush yadav on 24/03/26.
//

import Foundation

protocol NetworkMonitor {
    var isConnected: Bool { get }
    var onReconnect: (() -> Void)? { get set }
}
