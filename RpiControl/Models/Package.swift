//
//  Package.swift
//  RpiControl
//
//  Created by Oleg Mikhnovich on 24/12/2018.
//  Copyright © 2018 Oleg Mikhnovich. All rights reserved.
//

import Foundation

class Package {
    private var header: String = ""
    private var content: String = ""
    
    init(data: [UInt8]) {
        if let response = String(bytes: data, encoding: .utf8) {
            let responseArray = response.split(separator: "\n")
            if responseArray.count == 1 {
                self.header = String(responseArray[0])
                self.content = ""
            } else if responseArray.count >= 2 {
                self.header = String(responseArray[0])
                var body: String = ""
                for i in 1..<responseArray.count {
                    body += String(responseArray[i])
                }
                self.content = body
            }
        }
    }
    
    init(header: String, content: String) {
        self.header = header
        self.content = content
    }
    
    public func getHeader() -> String {
        return self.header
    }
    
    public func getContent() -> String {
        return self.content
    }
}
