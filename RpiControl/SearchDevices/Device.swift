//
//  Device.swift
//  RpiControl
//
//  Created by Admin on 14/12/2018.
//  Copyright © 2018 Oleg Mikhnovich. All rights reserved.
//

import Foundation

class Device {
    private var name: String
    private var type: String
    private var os: String
    private var ip: String
    
    init(rawPackage: String, ip: String) {
        let d = rawPackage.split(separator: "|")
        self.name = String(d[0])
        self.type = String(d[1])
        self.os = String(d[2])
        self.ip = ip
    }
    
    init(name: String, type: String, os: String, ip: String) {
        self.name = name
        self.type = type
        self.os = os
        self.ip = ip
    }
    
    public func getName() -> String {
        return self.name
    }
    
    public func getType() -> String {
        return self.type
    }
    
    public func getOS() -> String {
        return self.os
    }
    
    public func getIP() -> String {
        return self.ip
    }
}
