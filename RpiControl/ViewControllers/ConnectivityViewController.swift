//
//  ConnectivityViewController.swift
//  RpiControl
//
//  Created by Oleg Mikhnovich on 27/12/2018.
//  Copyright © 2018 Oleg Mikhnovich. All rights reserved.
//

import Cocoa

class ConnectivityViewController: NSTabViewController {
    @IBOutlet weak var directNameLabel: NSTextField!
    @IBOutlet weak var directIPLabel: NSTextField!
    @IBOutlet weak var directMacLabel: NSTextField!
    
    private var device: Device?
    
    override func viewDidLoad() {
        let dashboardInstance = self.parent as! DashboardViewController
        self.device = dashboardInstance.getDevice()
        
        freshDirectConnBtn([Any]())
    }
    
    @IBAction func freshDirectConnBtn(_ sender: Any) {
        guard let dev = device else { return }
        let connection = ConnectionAgent(address: dev.getIP())
        if connection.isConnected {
            if let res = connection.sendMessage(package: Package(header: "get-eth-connection", content: "...")) {
                if res.getHeader() == "get-eth-connection" {
                    let data = res.getContent().split(separator: "|")
                    if data.count == 3 {
                        directNameLabel.stringValue = "Name: \(String(data[0]))"
                        directIPLabel.stringValue = "IP: \(String(data[1]))"
                        directMacLabel.stringValue = "MAC: \(String(data[2]))"
                    }
                }
            }
        }
        connection.dispose()
    }
}
