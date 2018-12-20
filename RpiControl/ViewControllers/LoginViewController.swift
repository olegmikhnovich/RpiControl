//
//  LoginViewController.swift
//  RpiControl
//
//  Created by Oleg Mikhnovich on 20/12/2018.
//  Copyright © 2018 Oleg Mikhnovich. All rights reserved.
//

import Cocoa

class LoginViewController: NSViewController {
    private var device: Device?
    @IBOutlet weak var infoLabel: NSTextField!
    @IBOutlet weak var loginField: NSTextField!
    @IBOutlet weak var passwordField: NSSecureTextField!
    
    public func setDevice(device: Device) {
        self.device = device
    }
    
    override func viewDidAppear() {
        if device != nil {
            let name = device?.getName()
            let ip = device?.getIP()
            infoLabel.stringValue = "Connect to \"\(name!)@\(ip!)\""
        }
    }
    
    @IBAction func loginBtn(_ sender: Any) {
    }
    
    @IBAction func cancelBtn(_ sender: Any) {
        self.device = nil
        self.dismiss(self)
    }
}
