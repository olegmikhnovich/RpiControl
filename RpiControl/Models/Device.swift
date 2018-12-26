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
    
    init(raw: String, ip: String) {
        self.ip = ip
        
        let d = raw.split(separator: "|")
        if d.count == 3 {
            self.name = String(d[0])
            self.type = String(d[1])
            self.os = String(d[2])
        } else {
            self.name = "Unknown"
            self.type = "Unknown"
            self.os = "Unknown"
        }
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
