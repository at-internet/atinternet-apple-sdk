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
//  LiveAudio.swift
//  Tracker
//

import Foundation


/// Wrapper class for live audio tracking
public class LiveAudio: RichMedia {
   
    /// Media type
    @objc let type: String = "audio"
    
    /// Set parameters in buffer
    override func setEvent() {
        super.broadcastMode = .live
        
        super.setEvent()
        
        _ = self.tracker.setParam("type", value: type)
    }
    
}


/// Wrapper class to manage LiveAudio instances
public class LiveAudios: NSObject {
    
    @objc var list: [String: LiveAudio] = [String: LiveAudio]()
    
    /// MediaPlayer instance
    @objc var player: MediaPlayer
    
    /**
    LiveAudios initializer
    - parameter player: the player instance
    - returns: LiveAudios instance
    */
    @objc init(player: MediaPlayer) {
        self.player = player
    }
    
    /// Add a new live audio
    ///
    /// - Parameter name: audio name
    /// - Returns: new live audio instance
    @available(*, deprecated, renamed: "add(mediaLabel:)")
    @objc public func add(_ name:String) -> LiveAudio {
        if let audio = self.list[name] {
            self.player.tracker.delegate?.warningDidOccur?("A LiveAudio with the same name already exists.")
            return audio
        } else {
            let audio = LiveAudio(player: player)
            audio.mediaLabel = name
            
            self.list[name] = audio
            
            return audio
        }
    }
    
    /// Add a new live audio
    ///
    /// - Parameter mediaLabel: audio name
    /// - Returns: new live audio instance
    @objc public func add(mediaLabel _mediaLabel:String) -> LiveAudio {
        if let audio = self.list[_mediaLabel] {
            self.player.tracker.delegate?.warningDidOccur?("A LiveAudio with the same name already exists.")
            return audio
        } else {
            let audio = LiveAudio(player: player)
            audio.mediaLabel = _mediaLabel
            
            self.list[_mediaLabel] = audio
            
            return audio
        }
    }
    
    /// Add a new live audio
    ///
    /// - Parameters:
    ///   - name: name
    ///   - chapter1: chapter1 label
    /// - Returns: new live audio instance
    @available(*, deprecated, renamed: "add(mediaLabel:mediaTheme1:)")
    @objc public func add(_ name: String, chapter1: String) -> LiveAudio {
        if let audio = self.list[name] {
            self.player.tracker.delegate?.warningDidOccur?("A LiveAudio with the same name already exists.")
            return audio
        } else {
            let audio = LiveAudio(player: player)
            audio.mediaLabel = name
            audio.mediaTheme1 = chapter1
            
            self.list[name] = audio
            
            return audio
        }
    }
    
    /// Add a new live audio
    ///
    /// - Parameters:
    ///   - mediaLabel: name
    ///   - mediaTheme1: chapter1 label
    /// - Returns: new live audio instance
    @objc public func add(_ mediaLabel: String, mediaTheme1: String) -> LiveAudio {
        if let audio = self.list[mediaLabel] {
            self.player.tracker.delegate?.warningDidOccur?("A LiveAudio with the same name already exists.")
            return audio
        } else {
            let audio = LiveAudio(player: player)
            audio.mediaLabel = mediaLabel
            audio.mediaTheme1 = mediaTheme1
            
            self.list[mediaLabel] = audio
            
            return audio
        }
    }
    
    
    /// Add a new live audio
    ///
    /// - Parameters:
    ///   - name: name
    ///   - chapter1: chapter1 label
    ///   - chapter2: chapter2 label
    /// - Returns: a new live audio instance
    @available(*, deprecated, renamed: "add(mediaLabel:mediaTheme1:mediaTheme2:)")
    @objc public func add(_ name: String, chapter1: String, chapter2: String) -> LiveAudio {
        if let audio = self.list[name] {
            self.player.tracker.delegate?.warningDidOccur?("A LiveAudio with the same name already exists.")
            return audio
        } else {
            let audio = LiveAudio(player: player)
            audio.mediaLabel = name
            audio.mediaTheme1 = chapter1
            audio.mediaTheme2 = chapter2
            
            self.list[name] = audio
            
            return audio
        }
    }
    
    /// Add a new live audio
    ///
    /// - Parameters:
    ///   - mediaLabel: name
    ///   - mediaTheme1: chapter1 label
    ///   - mediaTheme2: chapter2 label
    /// - Returns: a new live audio instance
    @objc public func add(_ mediaLabel: String, mediaTheme1: String, mediaTheme2: String) -> LiveAudio {
        if let audio = self.list[mediaLabel] {
            self.player.tracker.delegate?.warningDidOccur?("A LiveAudio with the same name already exists.")
            return audio
        } else {
            let audio = LiveAudio(player: player)
            audio.mediaLabel = mediaLabel
            audio.mediaTheme1 = mediaTheme1
            audio.mediaTheme2 = mediaTheme2
            
            self.list[mediaLabel] = audio
            
            return audio
        }
    }
    
    /// Add a new live audio
    ///
    /// - Parameters:
    ///   - name: name
    ///   - chapter1: chapter1 label
    ///   - chapter2: chapter2 label
    ///   - chapter3: chapter3 label
    /// - Returns: a new live audio instance
    @available(*, deprecated, renamed: "add(mediaLabel:mediaTheme1:mediaTheme2:mediaTheme3:)")
    @objc public func add(_ name: String, chapter1: String, chapter2: String, chapter3: String) -> LiveAudio {
        if let audio = self.list[name] {
            self.player.tracker.delegate?.warningDidOccur?("A LiveAudio with the same name already exists.")
            return audio
        } else {
            let audio = LiveAudio(player: player)
            audio.mediaLabel = name
            audio.mediaTheme1 = chapter1
            audio.mediaTheme2 = chapter2
            audio.mediaTheme3 = chapter3
            
            self.list[name] = audio
            
            return audio
        }
    }
    
    /// Add a new live audio
    ///
    /// - Parameters:
    ///   - mediaLabel: name
    ///   - mediaTheme1: chapter1 label
    ///   - mediaTheme2: chapter2 label
    ///   - mediaTheme3: chapter3 label
    /// - Returns: a new live audio instance
    @objc public func add(_ mediaLabel: String, mediaTheme1: String, mediaTheme2: String, mediaTheme3: String) -> LiveAudio {
        if let audio = self.list[mediaLabel] {
            self.player.tracker.delegate?.warningDidOccur?("A LiveAudio with the same name already exists.")
            return audio
        } else {
            let audio = LiveAudio(player: player)
            audio.mediaLabel = mediaLabel
            audio.mediaTheme1 = mediaTheme1
            audio.mediaTheme2 = mediaTheme2
            audio.mediaTheme3 = mediaTheme3
            
            self.list[mediaLabel] = audio
            
            return audio
        }
    }
    
    /// Remove a live audio
    ///
    /// - Parameter name: name
    @available(*, deprecated, renamed: "remove(mediaLabel:)")
    @objc public func remove(_ name: String) {
        if let timer = list[name]?.timer {
            if timer.isValid {
                list[name]!.sendStop()
            }
        }
        self.list.removeValue(forKey: name)
    }
    
    /// Remove a live audio
    ///
    /// - Parameter mediaLabel: mediaLabel
    @objc public func remove(mediaLabel _mediaLabel: String) {
        if let timer = list[_mediaLabel]?.timer {
            if timer.isValid {
                list[_mediaLabel]!.sendStop()
            }
        }
        self.list.removeValue(forKey: _mediaLabel)
    }
    
    /// Remove all live audios
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
