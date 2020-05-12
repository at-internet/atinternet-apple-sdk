//
//  DynamicRefresh.swift
//  refreshdynamic
//
//  Created by Théo Damaville on 14/05/2018.
//  Copyright © 2018 Théo Damaville. All rights reserved.
//

import Foundation

/// Custom Timer
class DynamicRefresher {
    private let configuration: DynamicRefreshConfiguration
    private let sendRefresh: (() -> ()) // called when a refresh hit should be sent
    
    private var elapsedTime: Int = 0 // total time
    private var curr = 0 // current index of DynamicRefreshConfiguration
    private var timer: Timer? {
        willSet { self.timer?.invalidate() }
    }
    private var lastTick = Date(); // needed to handle pause

    deinit {
        self.timer = nil
    }

    init(configuration: DynamicRefreshConfiguration, sendRefresh: @escaping (() -> ()) ) {
        self.configuration = configuration
        self.sendRefresh = sendRefresh
    }
    
    public func start() {
        let refresh = self.configuration.getRefreshDuration(i: self.curr)
        self.timer = Timer.scheduledTimer(timeInterval: Double(refresh), target: self, selector: #selector(DynamicRefresher.process), userInfo: nil, repeats: false)
    }
    
    // called every tick
    @objc public func process() {
        let refresh = self.configuration.getRefreshDuration(i: self.curr)
        self.elapsedTime += refresh
        self.lastTick = Date()
        self.sendRefresh()
        
        if !self.configuration.isLastIndex(i: self.curr) {
            let nextMinute = self.configuration.getTime(i: self.curr+1)
            let nextRefreshDuration = self.configuration.getRefreshDuration(i: self.curr+1)
            if self.elapsedTime >= nextMinute * 60 {
                self.curr += 1
                self.timer = Timer.scheduledTimer(timeInterval: Double(nextRefreshDuration), target: self, selector: #selector(DynamicRefresher.process), userInfo: nil, repeats: false)
                return
            }
        }
        self.timer = Timer.scheduledTimer(timeInterval: Double(refresh), target: self, selector: #selector(DynamicRefresher.process), userInfo: nil, repeats: false)
    }
    
    public func pause() {
        let delta = -(self.lastTick.timeIntervalSinceNow)
        self.elapsedTime += Int(delta)
        self.timer = nil
    }
    
    public func resume() {
        self.start()
    }
    
    public func stop() {
        self.timer = nil
        self.elapsedTime = 0
        self.curr = 0
    }
}

/// Base object - can be sorted by startTime
class DynamicRefresh: Comparable, CustomStringConvertible {
    public let startTime: Int
    public let refreshDuration: Int
    init(startTime: Int, refreshDuration: Int) {
        self.startTime = startTime
        self.refreshDuration = refreshDuration
    }
    
    var description: String {return "{\(startTime):\(refreshDuration)}"}
    
    static func < (lhs: DynamicRefresh, rhs: DynamicRefresh) -> Bool {
        return lhs.startTime < rhs.startTime
    }
    
    static func == (lhs: DynamicRefresh, rhs: DynamicRefresh) -> Bool {
        return lhs.startTime == rhs.startTime
    }
}

/// Collection of <DynamicRefresh> - Each entry is converted in DynamicRefresh, added and then sorted
class DynamicRefreshConfiguration {
    private let dynamicRefreshes: Array<DynamicRefresh>
    init(configuration: Dictionary<Int, Int>) {
        self.dynamicRefreshes = configuration.map { (start, rd) -> DynamicRefresh in
            return DynamicRefresh(startTime: start, refreshDuration: rd)
            }.sorted()
    }
    
    public func isLastIndex(i: Int) -> Bool {
        return i+1 == dynamicRefreshes.count
    }
    
    public func get(i: Int) -> DynamicRefresh {
        return self.dynamicRefreshes[i]
    }
    
    public func getTime(i: Int) -> Int {
        return self.dynamicRefreshes[i].startTime
    }
    
    public func getRefreshDuration(i: Int) -> Int {
        return self.dynamicRefreshes[i].refreshDuration
    }
}
