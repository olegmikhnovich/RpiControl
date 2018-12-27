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
    @IBOutlet weak var pathControl: NSPathControl!
    
    private var device: Device?
    private let homeFolder: String = "/home/pi"
    private var currentFolder: String = ""
    var files: [UserFile] = []
    
    override func viewDidLoad() {
        let dashboardInstance = self.parent as! DashboardViewController
        self.device = dashboardInstance.getDevice()
        self.currentFolder = homeFolder

        filesTableView.delegate = self
        filesTableView.dataSource = self
        filesTableView.doubleAction = #selector(filesTableViewDoubleClick(_:))
        
        loadDirectory(directory: currentFolder)
    }
    
    @IBAction func backBtnClick(_ sender: Any) {
        if self.currentFolder == self.homeFolder { return }
        var rawPath = currentFolder.split(separator: "/")
        if let _ = rawPath.popLast() {
            self.currentFolder = "/" + rawPath.joined(separator: "/")
            loadDirectory(directory: self.currentFolder)
        }
    }
    
    @IBAction func homeBtnClick(_ sender: Any) {
        loadDirectory(directory: self.homeFolder)
    }
    
    @IBAction func freshBtnClick(_ sender: Any) {
        loadDirectory(directory: self.currentFolder)
    }
    
    private func loadDirectory(directory: String) {
        guard let dev = device else { return }
        let connection = ConnectionAgent(address: dev.getIP())
        if connection.isConnected {
            if let res = connection.sendMessage(package: Package(header: "get-dir", content: directory)) {
                if res.getHeader() == "get-dir" {
                    let data = res.getContent().split(separator: "^")
                    files.removeAll()
                    for d in data {
                        files.append(UserFile(raw: String(d)))
                    }
                    self.currentFolder = directory
                }
            }
        }
        connection.dispose()
        self.pathControl.url = URL(fileURLWithPath: self.currentFolder)
        self.filesTableView.reloadData()
    }
    
    private func loadFile(name: String, path: String) {
        guard let dev = device else { return }
        let connection = ConnectionAgent(address: dev.getIP())
        if connection.isConnected {
            if let res = connection.sendMessage(package: Package(header: "get-file", content: path)) {
                if res.getHeader() == "get-file" {
                    let home = FileManager.default.homeDirectoryForCurrentUser
                    let pathRaw = home.path + "/Downloads/" + name
                    let str = NSString(string: res.getContent()).replacingOccurrences(of: "\\n", with: "\n")
                    FileManager.default.createFile(atPath: pathRaw, contents: str.data(using: String.Encoding.utf8))
                }
            }
        }
        connection.dispose()
    }
    
    @objc func filesTableViewDoubleClick(_ sender:AnyObject) {
        if filesTableView.selectedRow >= 0 {
            let item = files[filesTableView.selectedRow]
            if item.getType() == item.dirType {
                self.currentFolder += "/" + item.getName()
                loadDirectory(directory: self.currentFolder)
            } else if item.getType() == item.fileType {
                let path = self.currentFolder + "/" + item.getName()
                loadFile(name: item.getName(), path: path)
            }
        }
    }
}
