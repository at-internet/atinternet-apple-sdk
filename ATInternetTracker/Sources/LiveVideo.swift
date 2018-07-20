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
//  LiveVideo.swift
//  Tracker
//

import Foundation


/// Wrapper class for Live Video tracking
public class LiveVideo: RichMedia {
   
    /// Media type
    let type: String = "video"
    
    /// Set parameters in buffer
    override func setEvent() {
        super.broadcastMode = .live
        
        super.setEvent()
        
        _ = self.tracker.setParam("type", value: type)
    }
    
}

/// Wrapper class to manage Live Audio instances
public class LiveVideos: NSObject {
    
    var list: [String: LiveVideo] = [String: LiveVideo]()
    
    /// MediaPlayer instance
    var player: MediaPlayer
    
    /**
    LiveVideos initializer
    - parameter player: the player instance
    - returns: LiveVideos instance
    */
    init(player: MediaPlayer) {
        self.player = player
    }
    
    /// Add a new live video
    ///
    /// - Parameter mediaLabel: live name
    /// - Returns: the new live video instance
    @objc public func add(_ mediaLabel:String) -> LiveVideo {
        if let video = self.list[mediaLabel] {
            self.player.tracker.delegate?.warningDidOccur?("A LiveVideo with the same name already exists.")
            return video
        } else {
            let video = LiveVideo(player: player)
            video.mediaLabel = mediaLabel
            
            self.list[mediaLabel] = video
            
            return video
        }
    }
    
    /// Add a new live video
    ///
    /// - Parameters:
    ///   - name: name
    ///   - chapter1: chapter1 label
    /// - Returns: a new live video instance
    @available(*, deprecated, renamed: "add(mediaLabel:mediaTheme1:)")
    @objc public func add(_ name: String, chapter1: String) -> LiveVideo {
        if let video = self.list[name] {
            self.player.tracker.delegate?.warningDidOccur?("A LiveVideo with the same name already exists.")
            return video
        } else {
            let video = LiveVideo(player: player)
            video.mediaLabel = name
            video.mediaTheme1 = chapter1
            
            self.list[name] = video
            
            return video
        }
    }
    
    /// Add a new live video
    ///
    /// - Parameters:
    ///   - mediaLabel: name
    ///   - mediaTheme1: chapter1 label
    /// - Returns: a new live video instance
    @objc public func add(_ mediaLabel: String, mediaTheme1: String) -> LiveVideo {
        if let video = self.list[mediaLabel] {
            self.player.tracker.delegate?.warningDidOccur?("A LiveVideo with the same name already exists.")
            return video
        } else {
            let video = LiveVideo(player: player)
            video.mediaLabel = mediaLabel
            video.mediaTheme1 = mediaTheme1
            
            self.list[mediaLabel] = video
            
            return video
        }
    }
    
    /// Add a new live video
    ///
    /// - Parameters:
    ///   - name: name
    ///   - chapter1: chapter1 label
    ///   - chapter2: chapter2 label
    /// - Returns: the new live video instance
    @available(*, deprecated, renamed: "add(mediaLabel:mediaTheme1:mediaTheme2:)")
    @objc public func add(_ name: String, chapter1: String, chapter2: String) -> LiveVideo {
        if let video = self.list[name] {
            self.player.tracker.delegate?.warningDidOccur?("A LiveVideo with the same name already exists.")
            return video
        } else {
            let video = LiveVideo(player: player)
            video.mediaLabel = name
            video.mediaTheme1 = chapter1
            video.mediaTheme2 = chapter2
            
            self.list[name] = video
            
            return video
        }
    }
    
    /// Add a new live video
    ///
    /// - Parameters:
    ///   - mediaLabel: name
    ///   - mediaTheme1: chapter1 label
    ///   - mediaTheme2: chapter2 label
    /// - Returns: the new live video instance
    @objc public func add(_ mediaLabel: String, mediaTheme1: String, mediaTheme2: String) -> LiveVideo {
        if let video = self.list[mediaLabel] {
            self.player.tracker.delegate?.warningDidOccur?("A LiveVideo with the same name already exists.")
            return video
        } else {
            let video = LiveVideo(player: player)
            video.mediaLabel = mediaLabel
            video.mediaTheme1 = mediaTheme1
            video.mediaTheme2 = mediaTheme2
            
            self.list[mediaLabel] = video
            
            return video
        }
    }

    /// Add a new live video
    ///
    /// - Parameters:
    ///   - name: name
    ///   - chapter1: chapter1 label
    ///   - chapter2: chapter2 label
    ///   - chapter3: chapter3 label
    /// - Returns: a new live video instance
    @available(*, deprecated, renamed: "add(mediaLabel:mediaTheme1:mediaTheme2:mediaTheme3:)")
    @objc public func add(_ name: String, chapter1: String, chapter2: String, chapter3: String) -> LiveVideo {
        if let video = self.list[name] {
            self.player.tracker.delegate?.warningDidOccur?("A LiveVideo with the same name already exists.")
            return video
        } else {
            let video = LiveVideo(player: player)
            video.mediaLabel = name
            video.mediaTheme1 = chapter1
            video.mediaTheme2 = chapter2
            video.mediaTheme3 = chapter3
            
            self.list[name] = video
            
            return video
        }
    }
    
    /// Add a new live video
    ///
    /// - Parameters:
    ///   - mediaLabel: name
    ///   - mediaTheme1: chapter1 label
    ///   - mediaTheme2: chapter2 label
    ///   - mediaTheme3: chapter3 label
    /// - Returns: a new live video instance
    @objc public func add(_ mediaLabel: String, mediaTheme1: String, mediaTheme2: String, mediaTheme3: String) -> LiveVideo {
        if let video = self.list[mediaLabel] {
            self.player.tracker.delegate?.warningDidOccur?("A LiveVideo with the same name already exists.")
            return video
        } else {
            let video = LiveVideo(player: player)
            video.mediaLabel = mediaLabel
            video.mediaTheme1 = mediaTheme1
            video.mediaTheme2 = mediaTheme2
            video.mediaTheme3 = mediaTheme3
            
            self.list[mediaLabel] = video
            
            return video
        }
    }
    
    /**
    Remove a live video
    - parameter mediaLabel: video name
    */
    @objc public func remove(_ mediaLabel: String) {
        if let timer = list[mediaLabel]?.timer {
            if timer.isValid {
                list[mediaLabel]!.sendStop()
            }
        }
        self.list.removeValue(forKey: mediaLabel)
    }
    
    /**
    Remove all live videos
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
