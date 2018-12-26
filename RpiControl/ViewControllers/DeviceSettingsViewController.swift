//
//  DeviceSettingsViewController.swift
//  RpiControl
//
//  Created by Oleg Mikhnovich on 25/12/2018.
//  Copyright © 2018 Oleg Mikhnovich. All rights reserved.
//

import Cocoa

class DeviceSettingsViewController: NSTabViewController {
    @IBOutlet weak var nameLabel: NSTextField!
    @IBOutlet weak var deviceLabel: NSTextField!
    @IBOutlet weak var osLabel: NSTextField!
    @IBOutlet weak var tempLabel: NSTextField!
    @IBOutlet weak var soundVolSlider: NSSlider!
    @IBOutlet weak var newDeviceField: NSTextField!
    @IBOutlet weak var oldPasswordField: NSSecureTextField!
    @IBOutlet weak var newPasswordField: NSSecureTextField!
    @IBOutlet weak var confirmNewPasswordField: NSSecureTextField!
    
    private var device: Device?
    
    override func viewDidLoad() {
        let dashboardInstance = self.parent as! DashboardViewController
        self.device = dashboardInstance.getDevice()
        
        loadMyDeviceInfo()
        loadSoundVolumeInfo()
    }
    
    private func loadMyDeviceInfo() {
        guard let dev = device else { return }
        let connection = ConnectionAgent(address: dev.getIP())
        if connection.isConnected {
            if let res = connection.sendMessage(package: Package(header: "device-info", content: "...")) {
                if res.getHeader() == "device-info" {
                    let d = res.getContent().split(separator: "|")
                    if d.count == 4 {
                        nameLabel.stringValue = "Name: \(String(d[0]))"
                        deviceLabel.stringValue = "Model: \(String(d[1]))"
                        osLabel.stringValue = "OS: \(String(d[2]))"
                        tempLabel.stringValue = "Temp: \(String(d[3]))"
                    }
                }
            }
        }
        connection.dispose()
    }
    
    private func loadSoundVolumeInfo() {
        guard let dev = device else { return }
        let connection = ConnectionAgent(address: dev.getIP())
        if connection.isConnected {
            if let res = connection.sendMessage(package: Package(header: "get-sound-volume", content: "...")) {
                if res.getHeader() == "get-sound-volume" {
                    soundVolSlider.doubleValue = Double(res.getContent()) ?? 0
                }
            }
        }
        connection.dispose()
    }
    
    private func showWarnAlert(title: String, info: String) {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = info
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
    @IBAction func freshDeviceInfo(_ sender: Any) {
        loadMyDeviceInfo()
    }
    
    @IBAction func changeSoundValue(_ sender: Any) {
        guard let dev = device else { return }
        let connection = ConnectionAgent(address: dev.getIP())
        if connection.isConnected {
            let soundValue = String(soundVolSlider.doubleValue)
            if let res = connection.sendMessage(package: Package(header: "set-sound-volume", content: soundValue)) {
                if res.getHeader() == "set-sound-volume" {
                    soundVolSlider.doubleValue = Double(res.getContent()) ?? 0
                }
            }
        }
        connection.dispose()
    }
    
    @IBAction func saveNewDeviceName(_ sender: Any) {
        guard let dev = device else { return }
        let connection = ConnectionAgent(address: dev.getIP())
        if connection.isConnected {
            if let res = connection.sendMessage(package: Package(header: "set-device-name", content: newDeviceField.stringValue)) {
                if res.getHeader() == "set-device-name" { loadMyDeviceInfo() }
            }
        }
        connection.dispose()
    }
    
    @IBAction func saveNewPassword(_ sender: Any) {
        if newPasswordField.stringValue != confirmNewPasswordField.stringValue { return }
        guard let dev = device else { return }
        let connection = ConnectionAgent(address: dev.getIP())
        if connection.isConnected {
            let pkg = oldPasswordField.stringValue + "|" + newPasswordField.stringValue
            if let res = connection.sendMessage(package: Package(header: "set-new-password", content: pkg)) {
                if res.getHeader() == "set-new-password" {
                    if res.getContent() == "true" {
                        showWarnAlert(title: "Successful operation", info: "Your password was changed successfully.")
                    } else {
                        showWarnAlert(title: "Unsuccessful operation", info: "Something went wrong. Try again later ...")
                    }
                }
            }
        }
        connection.dispose()
    }
    
    @IBAction func rebootBtnClick(_ sender: Any) {
        guard let dev = device else { return }
        let connection = ConnectionAgent(address: dev.getIP())
        if connection.isConnected {
            let _ = connection.sendMessage(package: Package(header: "reboot-device", content: "..."))
        }
        connection.dispose()
        self.view.window?.performClose(nil)
    }
    
    @IBAction func shutdownBtnClick(_ sender: Any) {
        guard let dev = device else { return }
        let connection = ConnectionAgent(address: dev.getIP())
        if connection.isConnected {
            let _ = connection.sendMessage(package: Package(header: "shutdown-device", content: "..."))
        }
        connection.dispose()
        self.view.window?.performClose(nil)
    }
    
}
