//
//  UserFile.swift
//  RpiControl
//
//  Created by Oleg Mikhnovich on 26/12/2018.
//  Copyright © 2018 Oleg Mikhnovich. All rights reserved.
//

import Foundation

class UserFile {
    private var name: String = ""
    private var type: String = ""
    
    init(raw: String) {
        let data = raw.split(separator: "|")
        if data.count == 2 {
            self.name = String(data[0])
            self.type = String(data[1])
        }
    }
    
    init(name: String, type: String) {
        self.name = name
        self.type = type
    }
    
    public func getName() -> String {
        return self.name
    }
    
    public func getType() -> String {
        return self.type
    }
    
}
