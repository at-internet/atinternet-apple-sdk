/*
 Copyright (c) 2014, Ashley Mills
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 
 1. Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 
 2. Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation
 and/or other materials provided with the distribution.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 */

#if !os(watchOS)

#if canImport(SystemConfiguration)
import SystemConfiguration
#endif
import Foundation

public let ReachabilityChangedNotification = "ReachabilityChangedNotification"


public class ATReachability: NSObject {
    
    public typealias NetworkReachable = (ATReachability) -> ()
    public typealias NetworkUnreachable = (ATReachability) -> ()
    
    public enum NetworkStatus: CustomStringConvertible {
        
        case notReachable, reachableViaWiFi, reachableViaWWAN
        
        public var description: String {
            switch self {
            case .reachableViaWWAN:
                return "Cellular"
            case .reachableViaWiFi:
                return "WiFi"
            case .notReachable:
                return "No Connection"
            }
        }
    }
    
    // MARK: - *** Public properties ***
    
    public var whenReachable: NetworkReachable?
    public var whenUnreachable: NetworkUnreachable?
    public var reachableOnWWAN: Bool
    public var notificationCenter = NotificationCenter.default
    
    public var currentReachabilityStatus: NetworkStatus {
        if isReachable() {
            if isReachableViaWiFi() {
                return .reachableViaWiFi
            }
            if isRunningOnDevice {
                return .reachableViaWWAN
            }
        }
        
        return .notReachable
    }
    
    public var currentReachabilityString: String {
        return "\(currentReachabilityStatus)"
    }
    
    // MARK: - *** Initialisation methods ***
    
    required public init?(reachabilityRef: SCNetworkReachability?) {
        reachableOnWWAN = true
        self.reachabilityRef = reachabilityRef
    }
    
    public convenience init?(hostname: String) {
        
        let nodename = (hostname as NSString).utf8String
        let ref = SCNetworkReachabilityCreateWithName(nil, nodename!)
        self.init(reachabilityRef: ref)
    }
    
    public class func reachabilityForInternetConnection() -> ATReachability? {
        if #available(iOS 9.0, *) {
            var zeroAddress = sockaddr_in6()
            zeroAddress.sin6_len = UInt8(MemoryLayout<sockaddr_in6>.size)
            zeroAddress.sin6_family = sa_family_t(AF_INET6)
            
            let ref = withUnsafePointer(to: &zeroAddress) {
                $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                    SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
                }
            }
            return ATReachability(reachabilityRef: ref)
        } else {
            var zeroAddress = sockaddr_in()
            zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
            zeroAddress.sin_family = sa_family_t(AF_INET)
            
            let ref = withUnsafePointer(to: &zeroAddress) {
                $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                    SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
                }
            }
            return ATReachability(reachabilityRef: ref)
        }
    }
    
    // MARK: - *** Notifier methods ***
    public func startNotifier() -> Bool {
        
        if notifierRunning { return true }
        
        var context = SCNetworkReachabilityContext(version: 0, info: nil, retain: nil, release: nil, copyDescription: nil)
        context.info = UnsafeMutableRawPointer(Unmanaged<ATReachability>.passUnretained(self).toOpaque())
        
        SCNetworkReachabilitySetCallback(reachabilityRef!,
                                         { (_, flags, info) in
                                            let reachability = Unmanaged<ATReachability>.fromOpaque(info!).takeUnretainedValue()
                                            
                                            DispatchQueue.main.async {
                                                reachability.reachabilityChanged(flags: flags)
                                            }
            }, &context)
        
        if SCNetworkReachabilitySetDispatchQueue(reachabilityRef!, reachabilitySerialQueue) {
            notifierRunning = true
            return true
        }
        
        stopNotifier()
        
        return false
    }
    
    
    public func stopNotifier() {
        if let reachabilityRef = reachabilityRef {
            SCNetworkReachabilitySetCallback(reachabilityRef, nil, nil)
        }
        notifierRunning = false
    }
    
    // MARK: - *** Connection test methods ***
    public func isReachable() -> Bool {
        return isReachableWithTest(test: { (flags: SCNetworkReachabilityFlags) -> (Bool) in
            return self.isReachableWithFlags(flags: flags)
        })
    }
    
    public func isReachableViaWWAN() -> Bool {
        
        if isRunningOnDevice {
            return isReachableWithTest() { flags -> Bool in
                // Check we're REACHABLE
                if self.isReachable(flags: flags) {
                    
                    // Now, check we're on WWAN
                    if self.isOnWWAN(flags: flags) {
                        return true
                    }
                }
                return false
            }
        }
        return false
    }
    
    public func isReachableViaWiFi() -> Bool {
        
        return isReachableWithTest() { flags -> Bool in
            
            // Check we're reachable
            if self.isReachable(flags: flags) {
                
                if self.isRunningOnDevice {
                    // Check we're NOT on WWAN
                    if self.isOnWWAN(flags: flags) {
                        return false
                    }
                }
                return true
            }
            
            return false
        }
    }
    
    // MARK: - *** Private methods ***
    private var isRunningOnDevice: Bool = {
        #if targetEnvironment(simulator)
            return false
        #else
            return true
        #endif
    }()
    
    private var notifierRunning = false
    private var reachabilityRef: SCNetworkReachability?
    private let reachabilitySerialQueue = DispatchQueue.init(label: "uk.co.ashleymills.reachability")
    
    private func reachabilityChanged(flags: SCNetworkReachabilityFlags) {
        if isReachableWithFlags(flags: flags) {
            if let block = whenReachable {
                block(self)
            }
        } else {
            if let block = whenUnreachable {
                block(self)
            }
        }
        
        notificationCenter.post(name: NSNotification.Name(rawValue: ReachabilityChangedNotification), object:self)
    }
    
    private func isReachableWithFlags(flags: SCNetworkReachabilityFlags) -> Bool {
        
        let reachable = isReachable(flags: flags)
        
        if !reachable {
            return false
        }
        
        if isConnectionRequiredOrTransient(flags: flags) {
            return false
        }
        
        if isRunningOnDevice {
            if isOnWWAN(flags: flags) && !reachableOnWWAN {
                // We don't want to connect when on 3G.
                return false
            }
        }
        
        return true
    }
    
    private func isReachableWithTest(test: (SCNetworkReachabilityFlags) -> (Bool)) -> Bool {
        
        if let reachabilityRef = reachabilityRef {
            
            var flags = SCNetworkReachabilityFlags(rawValue: 0)
            let gotFlags = withUnsafeMutablePointer(to: &flags) {
                SCNetworkReachabilityGetFlags(reachabilityRef, UnsafeMutablePointer($0))
            }
            
            if gotFlags {
                return test(flags)
            }
        }
        
        return false
    }
    
    // WWAN may be available, but not active until a connection has been established.
    // WiFi may require a connection for VPN on Demand.
    private func isConnectionRequired() -> Bool {
        return connectionRequired()
    }
    
    private func connectionRequired() -> Bool {
        return isReachableWithTest(test: { (flags: SCNetworkReachabilityFlags) -> (Bool) in
            return self.isConnectionRequired(flags: flags)
        })
    }
    
    // Dynamic, on demand connection?
    private func isConnectionOnDemand() -> Bool {
        return isReachableWithTest(test: { (flags: SCNetworkReachabilityFlags) -> (Bool) in
            return self.isConnectionRequired(flags: flags) && self.isConnectionOnTrafficOrDemand(flags: flags)
        })
    }
    
    // Is user intervention required?
    private func isInterventionRequired() -> Bool {
        return isReachableWithTest(test: { (flags: SCNetworkReachabilityFlags) -> (Bool) in
            return self.isConnectionRequired(flags: flags) && self.isInterventionRequired(flags: flags)
        })
    }
    
    private func isOnWWAN(flags: SCNetworkReachabilityFlags) -> Bool {
        #if os(iOS)
            return flags.contains(.isWWAN)
        #else
            return false
        #endif
    }
    private func isReachable(flags: SCNetworkReachabilityFlags) -> Bool {
        return flags.contains(.reachable)
    }
    private func isConnectionRequired(flags: SCNetworkReachabilityFlags) -> Bool {
        return flags.contains(.connectionRequired)
    }
    private func isInterventionRequired(flags: SCNetworkReachabilityFlags) -> Bool {
        return flags.contains(.interventionRequired)
    }
    private func isConnectionOnTraffic(flags: SCNetworkReachabilityFlags) -> Bool {
        return flags.contains(.connectionOnTraffic)
    }
    private func isConnectionOnDemand(flags: SCNetworkReachabilityFlags) -> Bool {
        return flags.contains(.connectionOnDemand)
    }
    func isConnectionOnTrafficOrDemand(flags: SCNetworkReachabilityFlags) -> Bool {
        return !flags.intersection([.connectionOnTraffic, .connectionOnDemand]).isEmpty
    }
    private func isTransientConnection(flags: SCNetworkReachabilityFlags) -> Bool {
        return flags.contains(.transientConnection)
    }
    private func isLocalAddress(flags: SCNetworkReachabilityFlags) -> Bool {
        return flags.contains(.isLocalAddress)
    }
    private func isDirect(flags: SCNetworkReachabilityFlags) -> Bool {
        return flags.contains(.isDirect)
    }
    private func isConnectionRequiredOrTransient(flags: SCNetworkReachabilityFlags) -> Bool {
        let testcase:SCNetworkReachabilityFlags = [.connectionRequired, .transientConnection]
        return flags.intersection(testcase) == testcase
    }
    
    private var reachabilityFlags: SCNetworkReachabilityFlags {
        if let reachabilityRef = reachabilityRef {
            
            var flags = SCNetworkReachabilityFlags(rawValue: 0)
            let gotFlags = withUnsafeMutablePointer(to: &flags) {
                SCNetworkReachabilityGetFlags(reachabilityRef, UnsafeMutablePointer($0))
            }
            
            if gotFlags {
                return flags
            }
        }
        
        return []
    }
    
    override public var description: String {
        
        var W: String
        if isRunningOnDevice {
            W = isOnWWAN(flags: reachabilityFlags) ? "W" : "-"
        } else {
            W = "X"
        }
        let R = isReachable(flags: reachabilityFlags) ? "R" : "-"
        let c = isConnectionRequired(flags: reachabilityFlags) ? "c" : "-"
        let t = isTransientConnection(flags: reachabilityFlags) ? "t" : "-"
        let i = isInterventionRequired(flags: reachabilityFlags) ? "i" : "-"
        let C = isConnectionOnTraffic(flags: reachabilityFlags) ? "C" : "-"
        let D = isConnectionOnDemand(flags: reachabilityFlags) ? "D" : "-"
        let l = isLocalAddress(flags: reachabilityFlags) ? "l" : "-"
        let d = isDirect(flags: reachabilityFlags) ? "d" : "-"
        
        return "\(W)\(R) \(c)\(t)\(i)\(C)\(D)\(l)\(d)"
    }
    
    deinit {
        stopNotifier()
        
        reachabilityRef = nil
        whenReachable = nil
        whenUnreachable = nil
    }
}
#endif
