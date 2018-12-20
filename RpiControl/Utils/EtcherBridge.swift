//
//  EtcherBridge.swift
//  RpiControl
//
//  Created by Admin on 19/12/2018.
//  Copyright © 2018 Oleg Mikhnovich. All rights reserved.
//

import Cocoa

extension EtcherBridge {
    var getProcess: AnyObject { return self.getProcess }
}

@objc(NSObject) protocol EtcherBridge {
    var getProcess: AnyObject { get } // Bool
}
