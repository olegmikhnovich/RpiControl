//
//  VolumesUtility.swift
//  RpiControl
//
//  Created by Oleg Mikhnovich on 18/12/2018.
//  Copyright © 2018 Oleg Mikhnovich. All rights reserved.
//

import Foundation
import Cocoa

class VolumesUtility {
    private var volumesComboBox: NSComboBox!
    
    @discardableResult
    init(comboBox volumesComboBox: NSComboBox!) {
        self.volumesComboBox = volumesComboBox
        self.loadVolumesList()
    }
    
    private func loadVolumesList() {
        let url = URL(fileURLWithPath:"/usr/bin/env")
        let pipe = Pipe()
        let task = Process()
        
        task.standardOutput = pipe
        task.executableURL = url
        task.arguments = ["diskutil", "list"]
        task.terminationHandler = { (process) in
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            guard let output = String(data: data, encoding: .utf8)?
                .split(separator: "\n") else { return }
            let blocks = self.getVolumeBlocksRaw(data: output)
            DispatchQueue.main.sync {
                self.volumesComboBox.removeAllItems()
                self.volumesComboBox.addItems(
                    withObjectValues: self.getVolumesList(data: blocks))
            }
        }
        do {
            try task.run()
        } catch {}
    }
    
    private func getVolumesList(data blocks:[[String]]) -> [String] {
        var volumes: [String] = []
        for block in blocks {
            let disk = block[0].split(separator: " ")[0]
            let spaceRaw = block[2].split(separator: " ")
            let space = (spaceRaw[2] + spaceRaw[3])[String.Index(encodedOffset: 1)...]
            volumes.append(disk + " " + space)
        }
        return volumes
    }
    
    private func getVolumeBlocksRaw(data output: [String.SubSequence]) -> [[String]] {
        var blocks: [[String]] = []
        var buffer: [String] = []
        var isValid: Bool = false
        for line in output {
            let str = String(line)
            if str[..<String.Index(encodedOffset: 1)] == "/" {
                if buffer.count > 0 {
                    blocks.append(buffer)
                    buffer.removeAll()
                }
                if str.range(of: "external") != nil {
                    isValid = true
                } else {
                    isValid = false
                }
            }
            if isValid {
                var components = str.components(separatedBy: .whitespaces)
                components.removeAll { (v) -> Bool in v == "" }
                buffer.append(components.joined(separator: " "))
            }
        }
        if buffer.count > 0 {
            blocks.append(buffer)
            buffer.removeAll()
        }
        return blocks
    }
}
