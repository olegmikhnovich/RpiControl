//
//  ConnectionAgent.swift
//  RpiControl
//
//  Created by Oleg Mikhnovich on 25/12/2018.
//  Copyright © 2018 Oleg Mikhnovich. All rights reserved.
//

import SwiftSocket

class ConnectionAgent {
    private let port: Int32 = 4822
    private let packageSize: Int = 8192
    
    private var client: TCPClient
    private var _isConnected: Bool
    private var address: String
    
    public var isConnected: Bool {
        get {
            return self._isConnected
        }
    }
    
    init(address: String) {
        self.address = address
        client = TCPClient(address: address, port: port)
        switch client.connect(timeout: 1) {
        case .success:
            _isConnected = true
        case .failure( _):
            _isConnected = false
        }
    }
    
    public func sendMessage(package: Package) -> Package? {
        var answer: Package? = nil
        switch client.send(string: "\(package.getHeader())^\(package.getContent())") {
        case .success:
            if let data = client.read(packageSize, timeout: 1) {
                answer = Package(data: data)
            }
        case .failure( _): break
        }
        return answer
    }
    
    public func dispose() {
        client.close()
        _isConnected = false
    }
}
