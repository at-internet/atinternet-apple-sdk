/*
This SDK is licensed under the MIT license (MIT)
Copyright (c) 2015- Applied Technologies Internet SAS (registration number B 403 261 258 - Trade and Companies Register of Bordeaux – France)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/





//
//  RichMedia.swift
//  Tracker
//

import Foundation


/// Abstract class to manage rich media tracking
public class RichMedia : BusinessObject {
    
    fileprivate var _isEmbedded: Bool?
    
    /// Rich media broadcast type
    ///
    /// - clip: clip
    /// - live: live
    @objc public enum BroadcastMode: Int {
        /// clip
        case clip = 0
        /// live
        case live = 1
    }
    
    /// Actions types
    ///
    /// - play: play
    /// - pause: pause
    /// - stop: stop
    /// - move: move
    /// - refresh: refresh
    @objc public enum RichMediaAction: Int {
        /// play
        case play = 0
        /// pause
        case pause = 1
        /// stop
        case stop = 2
        /// move
        case move = 3
        /// refresh
        case refresh = 4
        /// info
        case info = 5
        /// share
        case share = 6
        /// email
        case email = 7
        /// favor
        case favor = 8
        /// download
        case download = 9
    }
    
    /// Refresh timer
    var timer: Timer?
    
    /// true if media is buffering
    @available(*, deprecated,message: "useless, property set when send called")
    open var isBuffering: Bool = false {
        didSet {
        }
    }
    
    /// true if media is embedded in app
    open var isEmbedded: Bool = false {
        didSet {
            _isEmbedded = isEmbedded
        }
    }
    
    /// Media type
    @objc var type: String = ""
    
    /// Media type : live or clip
    var broadcastMode: BroadcastMode = BroadcastMode.clip
    
    /// Media name
    @available(*, deprecated, renamed: "mediaLabel")
    @objc public var name: String {
        get {
            return mediaLabel;
        }
        set {
            mediaLabel = newValue
        }
    }
    /// Media name
    @objc public var mediaLabel: String = ""
    
    /// First chapter
    @available(*, deprecated, renamed: "mediaTheme1")
    @objc public var chapter1: String? {
        get {
            return mediaTheme1
        }
        set {
            mediaTheme1 = newValue
        }
    }
    /// First chapter
    @objc public var mediaTheme1: String?
    
    /// Second chapter
    @available(*, deprecated, renamed: "mediaTheme2")
    @objc public var chapter2: String? {
        get {
            return mediaTheme2
        }
        set {
            mediaTheme2 = newValue
        }
    }
    /// Second chapter
    @objc public var mediaTheme2: String?
    
    /// Third chapter
    @available(*, deprecated, renamed: "mediaTheme3")
    @objc public var chapter3: String? {
        get {
            return mediaTheme3
        }
        set {
            mediaTheme3 = newValue
        }
    }
    
    /// Third chapter
    @objc public var mediaTheme3: String?
    
    /// Level 2
    @available(*, deprecated, renamed: "mediaLevel2")
    @objc public var level2: Int {
        get {
            return mediaLevel2
        }
        set {
            mediaLevel2 = newValue
        }
    }
    /// Level 2
    @objc public var mediaLevel2: Int {
        get {
            if let l = mediaLevel2String {
                return Int(l) ?? -1
            }
            return -1
        }
        set {
            if newValue >= 0 {
                mediaLevel2String = String(newValue)
            } else {
                mediaLevel2String = nil
            }
        }
    }
    
    /// Level 2
    @objc public var mediaLevel2String: String?
    
    /// Refresh Duration
    var refreshDuration: Int = 5
    
    /// Player Id
    var playerId: Int = -1
    
    /// Duration
    @objc public var duration: Int = 0
    
    /// Action. see RichMediaAction
    @available(*, deprecated,message: "useless, property set when send called")
    @objc public var action: RichMediaAction = RichMediaAction.play
    
    /// Web domain 
    @objc public var webdomain: String?
    
    /// Linked Content
    @objc public var linkedContent: String?
   
    /// default config for dynamic refresh
    let DynamicRefreshDefaultConfiguration = [0:5, 1:15, 5:30, 10: 60]
    var chronoRefresh: DynamicRefresher?
    
    init(tracker: Tracker, playerId: Int) {
        self.playerId = playerId
        super.init(tracker: tracker)
    }
    
    /// Set parameters in buffer
    override func setParams() {
        let encodingOption = ParamOption()
        encodingOption.encode = true
        
        _ = self.tracker.setParam("p", value: buildMediaName(), options: encodingOption)
        
        _ = self.tracker.setParam("plyr", value: self.playerId)
        
        _ = self.tracker.setParam("m6", value: broadcastMode == BroadcastMode.clip ? "clip" : "live")
        
        _ = self.tracker.setParam("type", value: type)
        
        if let optIsEmbedded = self._isEmbedded {
            _ = self.tracker.setParam("m5", value: optIsEmbedded ? "ext" : "int")
        }
        
        if let l = self.mediaLevel2String {
            _ = self.tracker.setParam("s2", value: l)
        }
    }
    
    /// Media name building
    func buildMediaName() -> String {
        var mediaName = mediaTheme1 == nil ? "" : mediaTheme1! + "::"
        mediaName = mediaTheme2 ==  nil ? mediaName : mediaName + mediaTheme2! + "::"
        mediaName = mediaTheme3 ==  nil ? mediaName : mediaName + mediaTheme3! + "::"
        mediaName += mediaLabel
        
        return mediaName
    }
    
    func setPlayOrInfoParams(){
        let encodingOption = ParamOption()
        encodingOption.encode = true
        
        if let optIsEmbedded = self._isEmbedded {
            if (optIsEmbedded) {
                if let optWebDomain = self.webdomain {
                    _ = self.tracker.setParam("m9", value: optWebDomain, options: encodingOption)
                }
            }
        }
        if let screenName = TechnicalContext.screenName {
            _ = self.tracker.setParam("prich", value: screenName, options: encodingOption)
        }
        if let level2 = TechnicalContext.level2 {
            _ = self.tracker.setParam("s2rich", value: level2)
        }
        if let optLinkedContent = self.linkedContent {
            _ = self.tracker.setParam("clnk", value: optLinkedContent, options: encodingOption)
        }
    }
    
    /// Send a play action tracking. Refresh is enabled with default refresh configuration. See doc for more details
    @objc public func sendPlay() {
        self.sendPlay(dynamicRefreshConfiguration: self.DynamicRefreshDefaultConfiguration)
    }
    
    /// Send a play action tracking. Refresh is enabled with default refresh configuration. See doc for more details
    @objc public func sendPlay(isBuffering: Bool) {
        _ = self.tracker.setParam("buf", value: isBuffering ? 1 : 0)
        sendPlay()
    }
    
    /// Send a play action tracking. Refresh is enabled with custom duration
    ///
    /// - Parameter refreshDuration: duration in second, must be >= 5
    @objc @available(*, deprecated, message: "Static values are not recomanded anymore. Use sendPlay() or sendPlay(dynamicRefreshConfiguration)")
    public func sendPlay(_ refreshDuration: Int) {
        var refreshDuration = refreshDuration
        if (refreshDuration == 0) {
            self.sendPlayWithoutRefresh()
            return
        }
        if (refreshDuration < 5) {
            refreshDuration = 5
        }
        self.sendPlay(dynamicRefreshConfiguration: [0: refreshDuration])
    }
    
    /// Send a play action. No refresh hits will be sent after the action.
    @objc public func sendPlayWithoutRefresh() {
        _ = self.tracker.setParam("a", value: "play")
        setPlayOrInfoParams()
        self.tracker.dispatcher.dispatch([self])
    }
    
    /// Send a play action. No refresh hits will be sent after the action.
    @objc public func sendPlayWithoutRefresh(isBuffering: Bool) {
        _ = self.tracker.setParam("buf", value: isBuffering ? 1 : 0)
        sendPlayWithoutRefresh()
    }
    
    /// Send a Play action then send several Resfresh action based on the configuration provided
    ///
    /// - Parameter dynamicRefreshConfiguration: Describe the refresh send rate: [0:5, 1:10] : from 0 to 1 minute, send one refresh every 5s, then refresh every 10s after 1min. See documentation for more details.
    @objc public func sendPlay(dynamicRefreshConfiguration: [Int: Int]) {
        var conf = dynamicRefreshConfiguration
        if conf.count == 0 {
            conf = DynamicRefreshDefaultConfiguration
        }
        if conf.index(forKey: 0) == nil {
            conf[0] = 5
        }
        for (min, rd) in conf {
            if rd < 5 {
                conf[min] = 5
            }
            if (min < 0) {
                conf.removeValue(forKey: min)
            }
        }
        let config = DynamicRefreshConfiguration(configuration: conf)
        self.chronoRefresh?.stop()
        self.chronoRefresh = DynamicRefresher(configuration: config) {
            [weak self] in self?.sendRefresh()
        }
        _ = self.tracker.setParam("a", value: "play")
        setPlayOrInfoParams()
        self.tracker.dispatcher.dispatch([self])
        self.chronoRefresh?.start()
    }
    
    /// Send a Play action then send several Resfresh action based on the configuration provided
    ///
    /// - Parameter dynamicRefreshConfiguration: Describe the refresh send rate: [0:5, 1:10] : from 0 to 1 minute, send one refresh every 5s, then refresh every 10s after 1min. See documentation for more details.
    @objc public func sendPlay(dynamicRefreshConfiguration: [Int: Int], isBuffering: Bool) {
        _ = self.tracker.setParam("buf", value: isBuffering ? 1 : 0)
        sendPlay(dynamicRefreshConfiguration: dynamicRefreshConfiguration)
    }
    
    /// Resume a previous pause() call
    @objc public func sendResume() {
        self.chronoRefresh?.resume()
        _ = self.tracker.setParam("a", value: "play")
        setPlayOrInfoParams()
        self.tracker.dispatcher.dispatch([self])
    }
    
    /// Resume a previous pause() call
    @objc public func sendResume(isBuffering: Bool) {
        _ = self.tracker.setParam("buf", value: isBuffering ? 1 : 0)
        sendResume()
    }
    
    /// Send a info action tracking
    @objc public func sendInfo() {
        _ = self.tracker.setParam("a", value: "info")
        setPlayOrInfoParams()
        self.tracker.dispatcher.dispatch([self])
    }
    
    /// Send a info action tracking
    @objc public func sendInfo(isBuffering: Bool) {
        _ = self.tracker.setParam("buf", value: isBuffering ? 1 : 0)
        sendInfo()
    }
    
    /// Send a pause action tracking
    @objc public func sendPause(){
        self.chronoRefresh?.pause()
        _ = self.tracker.setParam("a", value: "pause")
        self.tracker.dispatcher.dispatch([self])
    }
    
    
    /// Send a stop action tracking
    @objc public func sendStop() {
        self.chronoRefresh?.stop()
        _ = self.tracker.setParam("a", value: "stop")
        
        self.tracker.dispatcher.dispatch([self])
    }
    
    
    /// Send a move action tracking
    @objc public func sendMove() {
        _ = self.tracker.setParam("a", value: "move")

        self.tracker.dispatcher.dispatch([self])
    }
    
    /// Send a share action tracking
    @objc public func sendShare() {
        _ = self.tracker.setParam("a", value: "share")
        self.tracker.dispatcher.dispatch([self])
    }
    
    /// Send a email action tracking
    @objc public func sendEmail() {
        _ = self.tracker.setParam("a", value: "email")
        self.tracker.dispatcher.dispatch([self])
    }
    
    /// Send a favor action tracking
    @objc public func sendFavor() {
        _ = self.tracker.setParam("a", value: "favor")
        self.tracker.dispatcher.dispatch([self])
    }
    
    /// Send a download action tracking
    @objc public func sendDownload() {
        _ = self.tracker.setParam("a", value: "download")
        self.tracker.dispatcher.dispatch([self])
    }
    
    /// Medthod called on the timer tick
    @objc func sendRefresh() {
        _ = self.tracker.setParam("a", value: "refresh")
        self.tracker.dispatcher.dispatch([self])
    }
}
