//
//  TerminalViewController.swift
//  RpiControl
//
//  Created by Oleg Mikhnovich on 27/12/2018.
//  Copyright © 2018 Oleg Mikhnovich. All rights reserved.
//

import Cocoa

class TerminalViewController: NSTabViewController {
    @IBOutlet var termPanel: NSTextView!
    @IBOutlet weak var cmdBox: NSTextField!
    
    private var device: Device?
    
    override func viewDidLoad() {
        let dashboardInstance = self.parent as! DashboardViewController
        self.device = dashboardInstance.getDevice()
        termPanel.string = "~$ "
    }
    
    @IBAction func sendCmdBtn(_ sender: Any) {
        if cmdBox.stringValue.count > 0 {
            if cmdBox.stringValue == "clear" {
                termPanel.string = "~$ "
                cmdBox.stringValue = ""
                return
            }
            guard let dev = device else { return }
            let connection = ConnectionAgent(address: dev.getIP())
            if connection.isConnected {
                if let res = connection.sendMessage(package: Package(header: "exec-cmd", content: cmdBox.stringValue)) {
                    if res.getHeader() == "exec-cmd" {
                        termPanel.string += cmdBox.stringValue + "\n"
                        let data = NSString(string: res.getContent()).replacingOccurrences(of: "\\n", with: "\n")
                        termPanel.string += data + "\n\n" + "~$ "
                    }
                }
            }
            connection.dispose()
        }
        cmdBox.stringValue = ""
    }
    
    @IBAction func handleCmdBoxInput(_ sender: Any) {
        if cmdBox.stringValue.count > 0 {
            sendCmdBtn([Any]())
        }
    }
    
}
