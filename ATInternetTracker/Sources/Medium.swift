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
//  Medium.swift
//  Tracker
//

import Foundation

/// Wrapper class for Medium tracking
public class Medium: RichMedia {
    
    override init(tracker: Tracker, playerId: Int) {
        super.init(tracker: tracker, playerId: playerId)
        broadcastMode = BroadcastMode.clip
    }
    
    override func setParams() {
        super.setParams()
        
        if (self.duration > 86400) {
            self.duration = 86400
        }
        
        if (self.duration >= 0){
            _ = self.tracker.setParam("m1", value: duration)
        }
    }
}

/// Wrapper class to manage Medium instances
public class Media: NSObject {
    
    @objc var list: [String: Medium] = [String: Medium]()
    
    /// MediaPlayer instance
    @objc weak var player: MediaPlayer!
    
    /**
     Media initializer
     - parameter player: the player instance
     - returns: Media instance
     */
    @objc init(player: MediaPlayer) {
        self.player = player
    }
    
    /// Add a new medium
    ///
    /// - Parameters:
    ///   - mediaLabel: medium name
    ///   - mediaType: medium name
    ///   - duration: medium duration in seconds
    /// - Returns: the new medium instance
    @objc public func add(_ mediaLabel:String, mediaType:String, duration: Int) -> Medium {
        if let medium = self.list[mediaLabel] {
            self.player.tracker.delegate?.warningDidOccur?("A Medium with the same name already exists.")
            return medium
        } else {
            let medium = Medium(tracker: self.player.tracker, playerId: self.player.playerId)
            medium.mediaLabel = mediaLabel
            medium.duration = duration
            medium.type = mediaType
            
            self.list[mediaLabel] = medium
            
            return medium
        }
    }
    
    /// Add a new medium
    ///
    /// - Parameters:
    ///   - mediaLabel: medium name
    ///   - mediaTheme1: chapter1 label
    ///   - mediaType: medium type
    ///   - duration: medium duration in seconds
    /// - Returns: the new medium instance
    @objc public func add(_ mediaLabel: String, mediaTheme1: String, mediaType: String, duration: Int) -> Medium {
        let medium = add(mediaLabel, mediaType: mediaType, duration: duration)
        medium.mediaTheme1 = mediaTheme1
        return medium
    }
    
    /// Add a new medium
    ///
    /// - Parameters:
    ///   - mediaLabel: medium name
    ///   - mediaTheme1: chapter1 label
    ///   - mediaTheme2: chapter2 label
    ///   - mediaType: medium name
    ///   - duration: medium duration in seconds
    /// - Returns: the new medium instance
    @objc public func add(_ mediaLabel: String, mediaTheme1: String, mediaTheme2: String, mediaType: String, duration: Int) -> Medium {
        let medium = add(mediaLabel, mediaTheme1: mediaTheme1, mediaType: mediaType, duration: duration)
        medium.mediaTheme2 = mediaTheme2
        return medium
    }
    
    /// Add a new medium
    ///
    /// - Parameters:
    ///   - mediaLabel: medium name
    ///   - mediaTheme1: chapter1 label
    ///   - mediaTheme2: chapter2 label
    ///   - mediaTheme3: chapter3 label
    ///   - mediaType: medium name
    ///   - duration: medium duration in seconds
    /// - Returns: the new medium instance
    @objc public func add(_ mediaLabel: String, mediaTheme1: String, mediaTheme2: String, mediaTheme3: String, mediaType: String, duration: Int) -> Medium {
        let medium = add(mediaLabel, mediaTheme1: mediaTheme1, mediaTheme2: mediaTheme2, mediaType: mediaType, duration: duration)
        medium.mediaTheme3 = mediaTheme3
        return medium
    }
    
    /// Remove a medium
    ///
    /// - Parameter mediaLabel: medium name
    @available(*, deprecated, renamed: "remove(mediaLabel:)")
    @objc public func remove(_ mediaLabel: String) {
        if let timer = list[mediaLabel]?.timer {
            if timer.isValid {
                list[mediaLabel]!.sendStop()
            }
        }
        self.list.removeValue(forKey: mediaLabel)
    }
    
    /**
     Remove all media
     */
    @objc public func removeAll() {
        for (_, value) in self.list {
            if let timer = value.timer {
                if timer.isValid {
                    value.sendStop()
                }
            }
        }
        self.list.removeAll(keepingCapacity: false)
    }
}
