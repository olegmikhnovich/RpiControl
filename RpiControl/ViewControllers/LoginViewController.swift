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
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if (segue.identifier == "openControlWindow") {
            if sender != nil {
                let dashboardViewController = segue.destinationController as! DashboardViewController
                dashboardViewController.setDevice(device: sender as! Device)
            }
        }
    }
    
    private func showWarnAlert(title: String, info: String) {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = info
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
    @IBAction func loginBtn(_ sender: Any) {
        guard let dev = device else { return }
        let connection = ConnectionAgent(address: dev.getIP())
        if connection.isConnected {
            let pkg = "\(loginField.stringValue)\n\(passwordField.stringValue)"
            if let resp = connection.sendMessage(package: Package(header: "auth", content: pkg)) {
                if resp.getHeader() == "auth" && resp.getContent() == "true" {
                    self.performSegue(withIdentifier: "openControlWindow", sender: device)
                    self.dismiss(self)
                } else {
                    showWarnAlert(title: "Error", info: "Invalid username or password!")
                }
            } else {
                showWarnAlert(title: "Error", info: "An error occurred while sending a request.")
            }
        } else {
            showWarnAlert(title: "Client was disconnected!", info: "Try again later...")
        }
        connection.dispose()
    }
    
    @IBAction func cancelBtn(_ sender: Any) {
        self.device = nil
        self.dismiss(self)
    }
}
