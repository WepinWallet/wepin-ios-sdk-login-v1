//
//  NetworkMonitor.swift
//  WepinLogin
//
//  Created by iotrust on 6/17/24.
//

import Network

class NetworkMonitor {
    static let shared = NetworkMonitor()
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue.global(qos: .background)
    
    var isConnected: Bool = false
    
    private init() {
        monitor.pathUpdateHandler = { path in
            self.isConnected = path.status == .satisfied
            if self.isConnected {
//                print("Connected to the internet")
            } else {
//                print("No internet connection")
            }
        }
        monitor.start(queue: queue)
    }
}

