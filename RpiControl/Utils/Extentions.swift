//
//  Extentions.swift
//  RpiControl
//
//  Created by Oleg Mikhnovich on 14/12/2018.
//  Copyright © 2018 Oleg Mikhnovich. All rights reserved.
//

import Cocoa
import Foundation

extension String {
    func matches(pattern regex: String) -> [String] {
        do {
            let src = self as String
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: src, range: NSRange(src.startIndex..., in: src))
            return results.map { String(src[Range($0.range, in: src)!]) }
        } catch let error {
            print("Invalid regex: \(error.localizedDescription)")
            return []
        }
    }
    
    subscript (bounds: CountableClosedRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start...end])
    }
    
    subscript (bounds: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start..<end])
    }
}

extension HomeViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return devicesList.count
    }
}

extension HomeViewController: NSTableViewDelegate {
    fileprivate enum CellIdentifiers {
        static let NameCell = "NameCellID"
        static let TypeCell = "TypeCellID"
        static let OSCell = "OSCellID"
        static let IPV4Cell = "IPV4CellID"
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var text: String = ""
        var cellIdentifier: String = ""
        
        let item = devicesList[row]
        
        if tableColumn == tableView.tableColumns[0] {
            text = item.getName()
            cellIdentifier = CellIdentifiers.NameCell
        } else if tableColumn == tableView.tableColumns[1] {
            text = item.getType()
            cellIdentifier = CellIdentifiers.TypeCell
        } else if tableColumn == tableView.tableColumns[2] {
            text = item.getOS()
            cellIdentifier = CellIdentifiers.OSCell
        } else if tableColumn == tableView.tableColumns[3] {
            text = item.getIP()
            cellIdentifier = CellIdentifiers.IPV4Cell
        }
        
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = text
            return cell
        }
        return nil
    }
}



