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
//  Audio.swift
//  Tracker
//
import Foundation


/// Wrap class for audio media tracking
public class Audio: RichMedia {
    
    override init(tracker: Tracker, playerId: Int) {
        super.init(tracker: tracker, playerId: playerId)
        broadcastMode = BroadcastMode.clip
        type = "audio"
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


/// Wrapper class to manage Audio instances
public class Audios: NSObject {
    
    @objc var list: [String: Audio] = [String: Audio]()
    
    /// MediaPlayer instance
    @objc weak var player: MediaPlayer!
    
    /**
     Audios initializer
     - parameter player: the player instance
     - returns: Audios instance
     */
    @objc init(player: MediaPlayer) {
        self.player = player
    }
    
    /// Add a new Audio
    ///
    /// - Parameters:
    ///   - mediaLabel: audio name
    ///   - duration: duration of the track in second
    /// - Returns: the new Audio instance
    @objc public func add(_ mediaLabel:String, duration: Int) -> Audio {
        if let audio = self.list[mediaLabel] {
            self.player.tracker.delegate?.warningDidOccur?("An Audio with the same name already exists.")
            return audio
        } else {
            let audio = Audio(tracker: self.player.tracker, playerId: self.player.playerId)
            audio.mediaLabel = mediaLabel
            audio.duration = duration
            
            self.list[mediaLabel] = audio
            
            return audio
        }
    }
    
    /// Add a new Audio
    ///
    /// - Parameters:
    ///   - name: audio name
    ///   - chapter1: audio first chapter
    ///   - duration: duration of the track in second
    /// - Returns: the new Audio instance
    @available(*, deprecated, renamed: "add(mediaLabel:mediaTheme1:duration:)")
    @objc public func add(_ name: String, chapter1: String, duration: Int) -> Audio {
        return add(name, mediaTheme1: chapter1, duration: duration)
    }
    
    /// Add a new Audio
    ///
    /// - Parameters:
    ///   - mediaLabel: audio name
    ///   - mediaTheme1: audio first chapter
    ///   - duration: duration of the track in second
    /// - Returns: the new Audio instance
    @objc public func add(_ mediaLabel: String, mediaTheme1: String, duration: Int) -> Audio {
        let audio = add(mediaLabel, duration: duration)
        audio.mediaTheme1 = mediaTheme1
        return audio
    }
    
    /// Add a new Audio
    ///
    /// - Parameters:
    ///   - name: audio name
    ///   - chapter1: audio first chapter
    ///   - chapter2: audio second chapter
    ///   - duration: duration of the track in second
    /// - Returns: the new Audio instance
    @available(*, deprecated, renamed: "add(mediaLabel:mediaTheme1:mediaTheme2:duration:)")
    @objc public func add(_ name: String, chapter1: String, chapter2: String, duration: Int) -> Audio {
        return add(name, mediaTheme1: chapter1, mediaTheme2: chapter2, duration: duration)
    }
    
    /// Add a new Audio
    ///
    /// - Parameters:
    ///   - mediaLabel: audio name
    ///   - mediaTheme1: audio first chapter
    ///   - mediaTheme2: audio second chapter
    ///   - duration: duration of the track in second
    /// - Returns: the new Audio instance
    @objc public func add(_ mediaLabel: String, mediaTheme1: String, mediaTheme2: String, duration: Int) -> Audio {
        let audio = add(mediaLabel, mediaTheme1:mediaTheme1, duration: duration)
        audio.mediaTheme2 = mediaTheme2
        return audio
    }
    
    /// Add a new Audio
    ///
    /// - Parameters:
    ///   - name: audio name
    ///   - chapter1: audio first chapter
    ///   - chapter2: audio second chapter
    ///   - chapter3: audio third chapter
    ///   - duration: duration of the track in second
    /// - Returns: the new Audio instance
    @available(*, deprecated, renamed: "add(mediaLabel:mediaTheme1:mediaTheme2:mediaTheme3:duration:)")
    @objc public func add(_ name: String, chapter1: String, chapter2: String, chapter3: String, duration: Int) -> Audio {
        return add(name, mediaTheme1: chapter1, mediaTheme2: chapter2, mediaTheme3: chapter3, duration: duration)
    }
    
    /// Add a new Audio
    ///
    /// - Parameters:
    ///   - mediaLabel: audio name
    ///   - mediaTheme1: audio first chapter
    ///   - mediaTheme2: audio second chapter
    ///   - mediaTheme3: audio third chapter
    ///   - duration: duration of the track in second
    /// - Returns: the new Audio instance
    @objc public func add(_ mediaLabel: String, mediaTheme1: String, mediaTheme2: String, mediaTheme3: String, duration: Int) -> Audio {
        let audio = add(mediaLabel, mediaTheme1: mediaTheme1, mediaTheme2: mediaTheme2, duration: duration)
        audio.mediaTheme3 = mediaTheme3
        return audio
    }
    
    
    /// Remove an audio by name
    ///
    /// - Parameter mediaLabel: audio identified by name
    @objc public func remove(_ mediaLabel: String) {
        if let timer = list[mediaLabel]?.timer {
            if timer.isValid {
                list[mediaLabel]!.sendStop()
            }
        }
        self.list.removeValue(forKey: mediaLabel)
    }
    
    /// Remove all audios
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
