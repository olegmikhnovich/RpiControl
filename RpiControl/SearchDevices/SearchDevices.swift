//
//  SearchDevices.swift
//  RpiControl
//
//  Created by Admin on 13/12/2018.
//  Copyright © 2018 Oleg Mikhnovich. All rights reserved.
//

import Foundation
import SwiftSocket

class SearchDevices {
    
    public func getDevices() -> [Device] {
        var devices = [Device]()
        let backgroundQueue = DispatchQueue.global(qos: .background)
        let addresses = getIFAddresses()
        backgroundQueue.sync {
            for range in addresses {
                devices.append(contentsOf: self.requestHost(range: range))
            }
        }
        return devices
    }
    
    func requestHost(range: String) -> [Device] {
        var devices = [Device]()
        let pref = self.getAddressRange(address: range)
        let queue = OperationQueue()
        for i in 1..<255 {
            queue.addOperation {
                let client = TCPClient(address: "\(pref).\(i)", port: 4822)
                switch client.connect(timeout: 1) {
                case .success:
                    switch client.send(string: "mikhnovich.oleg.rpicontrol" ) {
                    case .success:
                        let data = client.read(1024, timeout: 1)
                        if let response = String(bytes: data ?? [UInt8](), encoding: .utf8) {
                            devices.append(Device(rawPackage: response, ip: "\(pref).\(i)"))
                        }
                    case .failure( _): break
                    }
                case .failure( _): break
                }
                client.close()
            }
        }
        queue.waitUntilAllOperationsAreFinished()
        return devices
    }
    
    private func getAddressRange(address: String) -> String {
        var addr = address.split(separator: ".")
        addr.remove(at: 3)
        return addr.joined(separator: ".")
    }
    
    private func getIFAddresses() -> [String] {
        var addresses = [String]()
        
        // Get list of all interfaces on the local machine:
        var ifaddr : UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return [] }
        guard let firstAddr = ifaddr else { return [] }
        
        // For each interface ...
        for ptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let flags = Int32(ptr.pointee.ifa_flags)
            let addr = ptr.pointee.ifa_addr.pointee
            
            // Check for running IPv4, IPv6 interfaces. Skip the loopback interface.
            if (flags & (IFF_UP|IFF_RUNNING|IFF_LOOPBACK)) == (IFF_UP|IFF_RUNNING) {
                if addr.sa_family == UInt8(AF_INET) || addr.sa_family == UInt8(AF_INET6) {
                    
                    // Convert interface address to a human readable string:
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    if (getnameinfo(ptr.pointee.ifa_addr, socklen_t(addr.sa_len), &hostname, socklen_t(hostname.count),
                                    nil, socklen_t(0), NI_NUMERICHOST) == 0) {
                        let address = String(cString: hostname)
                        addresses.append(address)
                    }
                }
            }
        }
        freeifaddrs(ifaddr)
        
        var result = [String]()
        for addr in addresses {
            let match = addr.matches(pattern: "([0-9A-Fa-f]{1,4}:){7}[0-9A-Fa-f]{1,4}|(\\d{1,3}\\.){3}\\d{1,3}")
            if match.count > 0 {
                result.append(match[0])
            }
        }
        return result
    }
}
