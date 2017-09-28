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
    
    fileprivate var _isBuffering: Bool?
    fileprivate var _isEmbedded: Bool?
    
    /// Rich media broadcast type
    ///
    /// - clip: clip
    /// - live: live
    public enum BroadcastMode: String {
        /// clip
        case clip = "clip"
        /// live
        case live = "live"
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
    }
    
    /// Player instance
    var player: MediaPlayer
    
    /// Refresh timer
    var timer: Timer?
    
    /// true if media is buffering
    open var isBuffering: Bool = false {
        didSet {
            _isBuffering = isBuffering
        }
    }
    
    /// true if media is embedded in app
    open var isEmbedded: Bool = false {
        didSet {
            _isEmbedded = isEmbedded
        }
    }
    
    /// Media type : live or clip
    var broadcastMode: BroadcastMode = BroadcastMode.clip
    
    /// Media name
    @objc public var name: String = ""
    
    /// First chapter
    @objc public var chapter1: String?
    
    /// Second chapter
    @objc public var chapter2: String?
    
    /// Third chapter
    @objc public var chapter3: String?
    
    /// Level 2
    @objc public var level2: Int = 0
    
    /// Refresh Duration
    var refreshDuration: Int = 5
    
    /// Action. see RichMediaAction
    @objc public var action: RichMediaAction = RichMediaAction.play
    
    /// Web domain 
    @objc public var webdomain: String?
   
    init(player: MediaPlayer) {
        self.player = player
        
        super.init(tracker: player.tracker)
    }
    
    fileprivate func getActionEnumRawValue(_ value: Int) -> String {
        switch value {
        case 0:
            return "play"
        case 1:
            return "pause"
        case 2:
            return "stop"
        case 3:
            return "move"
        case 4:
            return "refresh"
        default:
            return "play"
        }
    }
    
    /// Set parameters in buffer
    override func setEvent() {
        let encodingOption = ParamOption()
        encodingOption.encode = true
        
        _ = self.tracker.setParam("p", value: buildMediaName(), options: encodingOption)
        
        _ = self.tracker.setParam("plyr", value: player.playerId)
        
        _ = self.tracker.setParam("m6", value: broadcastMode.rawValue)
        
        _ = self.tracker.setParam("a", value: getActionEnumRawValue(action.rawValue))
        
        if let optIsEmbedded = self._isEmbedded {
            _ = self.tracker.setParam("m5", value: optIsEmbedded ? "ext" : "int")
        }
        
        if self.level2 > 0 {
            _ = self.tracker.setParam("s2", value: level2)
        }
        
        if(action == RichMediaAction.play) {
            if let optIsBuffering = self._isBuffering {
                _ = self.tracker.setParam("buf", value: optIsBuffering ? 1 : 0)
            }
            
            if let optIsEmbedded = self._isEmbedded {
                if (optIsEmbedded) {
                    if let optWebDomain = self.webdomain {
                        _ = self.tracker.setParam("m9", value: optWebDomain)
                    }
                } else {
                    if TechnicalContext.screenName != "" {
                        _ = self.tracker.setParam("prich", value: TechnicalContext.screenName, options: encodingOption)
                    }
                    
                    if TechnicalContext.level2 > 0 {
                        _ = self.tracker.setParam("s2rich", value: TechnicalContext.level2)
                    }
                }
            }
            
        }
    }
    
    /// Media name building
    func buildMediaName() -> String {
        var mediaName = chapter1 == nil ? "" : chapter1! + "::"
        mediaName = chapter2 ==  nil ? mediaName : mediaName + chapter2! + "::"
        mediaName = chapter3 ==  nil ? mediaName : mediaName + chapter3! + "::"
        mediaName += name
        
        return mediaName
    }
    
    /// Send a play action tracking. Refresh is enabled with default duration
    @objc public func sendPlay() {
        self.action = RichMediaAction.play
        
        self.tracker.dispatcher.dispatch([self])
        
        self.initRefresh()
    }
    
    /// Send a play action tracking. Refresh is enabled with custom duration
    ///
    /// - Parameter refreshDuration: duration in second, must be >= 5
    @objc public func sendPlay(_ refreshDuration: Int) {
        
        self.action = RichMediaAction.play
        
        self.tracker.dispatcher.dispatch([self])
        
        if (refreshDuration != 0) {
            if (refreshDuration > 5) {
                self.refreshDuration = refreshDuration
            }
            self.initRefresh()
        }
        
    }
    
    /// Send a pause action tracking
    @objc public func sendPause(){
        
        if let timer = self.timer {
            if timer.isValid {
                timer.invalidate()
                self.timer = nil
            }
        }
        
        self.action = RichMediaAction.pause
        
        self.tracker.dispatcher.dispatch([self])
    }
    
    
    /// Send a stop action tracking
    @objc public func sendStop() {
        
        if let timer = self.timer {
            if timer.isValid {
                timer.invalidate()
                self.timer = nil
            }
        }
        
        self.action = RichMediaAction.stop
        
        self.tracker.dispatcher.dispatch([self])
    }
    
    
    /// Send a move action tracking
    @objc public func sendMove() {
        self.action  = RichMediaAction.move
        
        self.tracker.dispatcher.dispatch([self])
    }
    
    /// Start the refresh timer
    func initRefresh() {
        if self.timer == nil {
            self.timer = Timer.scheduledTimer(
                timeInterval: TimeInterval(self.refreshDuration), target: self, selector: #selector(RichMedia.sendRefresh), userInfo: nil, repeats: true)
        }
        
    }
    
    /// Medthod called on the timer tick
    @objc func sendRefresh() {
        self.action = RichMediaAction.refresh
        
        self.tracker.dispatcher.dispatch([self])
    }
    
}
