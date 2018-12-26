//
//  MainViewController.swift
//  RpiControl
//
//  Created by Oleg Mikhnovich on 13/12/2018.
//  Copyright © 2018 Oleg Mikhnovich. All rights reserved.
//

import Cocoa

class HomeViewController: NSViewController {
    @IBOutlet weak var scanButton: NSButton!
    @IBOutlet weak var scanProgressIndicator: NSProgressIndicator!
    @IBOutlet weak var dashboardTable: NSTableView!
    @IBOutlet weak var tabsControl: NSTabView!
    @IBOutlet weak var volumesComboBox: NSComboBox!
    @IBOutlet weak var filePathStatusLabel: NSTextField!
    @IBOutlet weak var flashInfoLabel: NSTextField!
    @IBOutlet weak var flashProgress: NSProgressIndicator!
    @IBOutlet weak var startFlashButton: NSButton!
    @IBOutlet weak var searchBox: NSSearchField!
    
    var devicesList: [Device] = []
    var devicesListCache: [Device] = []
    var firmwareFilePath: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initSearchTable()
        self.initUIComponentsState()
    }
    
    func initSearchTable() {
        dashboardTable.delegate = self
        dashboardTable.dataSource = self
        dashboardTable.doubleAction = #selector(tableViewDoubleClick(_:))
    }
    
    func initUIComponentsState() {
        scanProgressIndicator.isHidden = true
        scanProgressIndicator.startAnimation(self)
        VolumesUtility(comboBox: self.volumesComboBox)
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if (segue.identifier == "openLoginView") {
            if sender != nil {
                let dev = sender as! Device
                let loginController = segue.destinationController as! LoginViewController
                loginController.setDevice(device: dev)
            }
        }
    }
    
    @objc func tableViewDoubleClick(_ sender:AnyObject) {
        if dashboardTable.selectedRow >= 0 {
            let item = devicesList[dashboardTable.selectedRow]
            self.performSegue(withIdentifier: "openLoginView", sender: item)
        }
    }
    
    func dialogOKCancel(question: String, text: String) -> Bool {
        let alert = NSAlert()
        alert.messageText = question
        alert.informativeText = text
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")
        return alert.runModal() == .alertFirstButtonReturn
    }
    
    @IBAction func searchChangedAction(_ sender: Any) {
        let searchRequest = searchBox.stringValue.lowercased()
        if devicesListCache.count > 0 {
            devicesList = devicesListCache
            devicesListCache = []
        }
        if searchRequest.count > 0 {
            devicesListCache = devicesList
            devicesList = []
            var flag: Bool = false
            for d in devicesListCache {
                flag = false
                if d.getName().lowercased().range(of: searchRequest) != nil { flag = true }
                if d.getType().lowercased().range(of: searchRequest) != nil { flag = true }
                if d.getOS().lowercased().range(of: searchRequest) != nil { flag = true }
                if d.getIP().lowercased().range(of: searchRequest) != nil { flag = true }
                if flag == true { devicesList.append(d) }
            }
        }
        self.dashboardTable.reloadData()
    }
    
    @IBAction func freshVolumesList(_ sender: Any) {
        VolumesUtility(comboBox: self.volumesComboBox)
    }
    
    @IBAction func scanDevices(_ sender: Any) {
        let backgroundQueue = DispatchQueue.global(qos: .background)
        scanButton.isHidden = true
        scanProgressIndicator.isHidden = false
        backgroundQueue.async {
            let search = SearchDevices()
            self.devicesList = search.getDevices()
            DispatchQueue.main.sync {
                self.dashboardTable.reloadData()
                self.scanButton.isHidden = false
                self.scanProgressIndicator.isHidden = true
            }
        }
    }
    
    @IBAction func selectFrirwareFile(_ sender: Any) {
        let dialog = NSOpenPanel();
        dialog.title = "Choose a firmware file"
        dialog.showsResizeIndicator = true
        dialog.showsHiddenFiles = false
        dialog.canChooseDirectories = true
        dialog.canCreateDirectories = true
        dialog.allowsMultipleSelection = false
        dialog.allowedFileTypes = ["zip", "img", "iso"];
        
        if (dialog.runModal() == NSApplication.ModalResponse.OK) {
            let result = dialog.url
            if (result != nil) {
                let path = result!.path
                firmwareFilePath = path
                filePathStatusLabel.stringValue = path
            }
        } else {
            firmwareFilePath = ""
            return
        }
    }
    
    @IBAction func downloadAndFlashBtn(_ sender: Any) {
        if let selectedDriveValue = volumesComboBox.objectValueOfSelectedItem as? String {
            let device = selectedDriveValue.split(separator: " ")[0]
            if firmwareFilePath.count > 0 {
                if dialogOKCancel(question: "Please, confirm selected configuration.\nProcess can't be undone!", text: "Firmware URL: \(firmwareFilePath)\nDevice: \(device)") {
                    
                    let writeFirmwareQueue = DispatchQueue.global(qos: .background)
                    let updateProgressQueue = DispatchQueue.global(qos: .background)
                    
                    let outFileName: String = FileManager().homeDirectoryForCurrentUser.path  + "/.rpicontrol_etcher_log.txt"
                    
                    let writeFirmwareWorkItem = DispatchWorkItem {
                        let script = "do shell script \"/opt/etcher-cli/balena-etcher -d \(device) -y \(self.firmwareFilePath) > \(outFileName)\" with administrator privileges"
                        let appleScript = NSAppleScript(source: script)
                        let err = appleScript?.executeAndReturnError(nil)
                        if err != nil {
                            updateProgressQueue.resume()
                        }
                    }
                    
                    var isRunning: Bool = true
                    var file: FileHandle? = nil
                    
                    let updateProgressWorkItem = DispatchWorkItem {
                        if let f = FileHandle(forReadingAtPath: outFileName) {
                            f.closeFile()
                            do {
                                try FileManager.default.removeItem(atPath: outFileName)
                            } catch { }
                        }
                        
                        while (true) {
                            file = FileHandle(forReadingAtPath: outFileName)
                            if file != nil || !isRunning { break }
                            sleep(1)
                        }
                        
                        var fileSeek: UInt64 = 0
                        while (isRunning) {
                            file?.synchronizeFile()
                            file?.seek(toFileOffset: fileSeek)
                            if let data = file?.readDataToEndOfFile() {
                                if data.count > 0 {
                                    if let str = String(data: data, encoding: String.Encoding.utf8) {
                                        if str.contains("%") {
                                            let sp = str.split(separator: "]")
                                            var stateProc = String((sp[0].split(separator: ":")[0])[String.Index(encodedOffset: 4)...])
                                            stateProc = stateProc.trimmingCharacters(in: ["\n", "[", "1", "A"])
                                            let progressValue = String(sp[1].split(separator: "%")[0]).trimmingCharacters(in: [" "])
                                            DispatchQueue.main.async {
                                                self.flashInfoLabel.stringValue = stateProc + ": " + progressValue + "% " + String(sp[1].split(separator: "%")[1].split(separator: "\n")[0])
                                                self.flashProgress.doubleValue = Double(progressValue) ?? 0
                                            }
                                        }
                                    }
                                }
                                fileSeek = file?.seekToEndOfFile() ?? 0
                            }
                            sleep(1)
                        }
                    }
                    
                    DispatchQueue.main.async {
                        self.startFlashButton.isEnabled = false
                        self.flashProgress.doubleValue = 0
                        self.flashInfoLabel.stringValue = ""
                    }
                    writeFirmwareQueue.async(execute: writeFirmwareWorkItem)
                    writeFirmwareWorkItem.notify(queue: updateProgressQueue) {
                        isRunning = false
                        file?.closeFile()
                        do {
                            try FileManager.default.removeItem(atPath: outFileName)
                        } catch { }
                        DispatchQueue.main.async {
                            self.startFlashButton.isEnabled = true
                            self.flashProgress.doubleValue = 0
                            self.flashInfoLabel.stringValue = ""
                        }
                    }
                    updateProgressQueue.async(execute: updateProgressWorkItem)
                }
            }
        }
    }
}
