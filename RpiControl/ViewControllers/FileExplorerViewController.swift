//
//  FileExplorerViewController.swift
//  RpiControl
//
//  Created by Oleg Mikhnovich on 26/12/2018.
//  Copyright © 2018 Oleg Mikhnovich. All rights reserved.
//

import Cocoa

class FileExplorerViewController: NSTabViewController {
    @IBOutlet weak var filesTableView: NSTableView!
    
    private var device: Device?
    var files: [UserFile] = []
    
    override func viewDidLoad() {
        let dashboardInstance = self.parent as! DashboardViewController
        self.device = dashboardInstance.getDevice()

        filesTableView.delegate = self
        filesTableView.dataSource = self
        
        loadDirectory()
    }
    
    private func loadDirectory() {
        guard let dev = device else { return }
        let connection = ConnectionAgent(address: dev.getIP())
        if connection.isConnected {
            if let res = connection.sendMessage(package: Package(header: "get-dir", content: "home")) {
                if res.getHeader() == "get-dir" {
                    let data = res.getContent().split(separator: "^")
                    for d in data {
                        files.append(UserFile(raw: String(d)))
                    }
                }
            }
        }
        connection.dispose()
        self.filesTableView.reloadData()
    }
    
}
