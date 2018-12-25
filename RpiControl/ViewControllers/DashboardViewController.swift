//
//  DashboardViewController.swift
//  RpiControl
//
//  Created by Admin on 24/12/2018.
//  Copyright © 2018 Oleg Mikhnovich. All rights reserved.
//

import Cocoa

class DashboardViewController: NSTabViewController {
    private var device: Device?
    
    public func setDevice(device: Device) {
        self.device = device
    }
    
    
    override func viewDidAppear() {
        super.viewDidAppear()
        if device != nil {
            self.view.window?.title = "RpiControl \(device!.getName())@\(device!.getIP())"
            self.view.window?.titlebarAppearsTransparent = true
        }
    }
}
