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
//  AVInsights.swift
//  Tracker
//
import Foundation

public class AVInsights: NSObject {
    private var events : Events
    
    init(tracker: Tracker) {
        self.events = tracker.events
    }
    
    @objc public var media : AVMedia {
        get {
            return AVMedia(events: self.events, sessionId: nil)
        }
    }
    
    @objc public func Media(heartbeat: Int, bufferHeartbeat: Int) -> AVMedia {
        return AVMedia(events: self.events, heartbeat: nil, bufferHeartbeat: nil, sessionId: nil)
    }
    
    @objc public func Media(heartbeat: Int, bufferHeartbeat: Int, sessionId: String?) -> AVMedia {
        return AVMedia(events: self.events, heartbeat: nil, bufferHeartbeat: nil, sessionId: sessionId)
    }
    
    @objc(MediaWithDynamicValues::)
    public func Media(heartbeat: [Int:Int]?, bufferHeartbeat: [Int:Int]?) -> AVMedia {
        return AVMedia(events: self.events, heartbeat: heartbeat, bufferHeartbeat: bufferHeartbeat, sessionId: nil)
    }
    
    @objc(MediaWithDynamicValues:::)
    public func Media(heartbeat: [Int:Int]?, bufferHeartbeat: [Int:Int]?, sessionId: String?) -> AVMedia {
        return AVMedia(events: self.events, heartbeat: heartbeat, bufferHeartbeat: bufferHeartbeat, sessionId: sessionId)
    }
}
