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
//  Player.swift
//  Tracker
//

import Foundation


/// Wrapper class to manage rich media tracking
public class MediaPlayer: NSObject {
    /// Tracker instance
    var tracker: Tracker
    
    /// Player ID
    @objc public var playerId: Int = 1
    
    /// List of videos attached to this player
    @objc public lazy var videos: Videos = Videos(player: self)
    
    /// List of audios attached to this player
    @objc public lazy var audios: Audios = Audios(player: self)
    
    /// List of live videos attached to this player
    @objc public lazy var liveVideos: LiveVideos = LiveVideos(player: self)
    
    /// List of live audios attached to this player
    @objc public lazy var liveAudios: LiveAudios = LiveAudios(player: self)
    
    /// List of medias attached to this player
    @objc public lazy var media: Media = Media(player: self)
    
    /// List of medias attached to this player
    @objc public lazy var liveMedia: LiveMedia = LiveMedia(player: self)
    
    /**
    Players initializer
    - parameter tracker: the tracker instance
    - returns: Players instance
    */
    init(tracker: Tracker) {
        self.tracker = tracker
    }    
}


/// Wrapper class to manage media players
public class MediaPlayers: NSObject {
    /// Tracker instance
    var tracker: Tracker
    
    /// Player ids
    lazy var playerIds: [Int: MediaPlayer] = [Int: MediaPlayer]()
    
    /**
    Players initializer
    - parameter tracker: the tracker instance
    - returns: Players instance
    */
    init(tracker: Tracker) {
        self.tracker = tracker
    }
    
    /// Add a new Media Player
    ///
    /// - Returns: the new MediaPlayer instance
    @objc public func add() -> MediaPlayer {
        let player = MediaPlayer(tracker: tracker)
        
        if playerIds.count > 0 {
            player.playerId = playerIds.keys.max()! + 1
        } else {
            player.playerId = 1
        }
        
        playerIds[player.playerId] = player
        
        return player
    }

    /// Add a new Media Player
    ///
    /// - Parameter playerId: the player identifier
    /// - Returns: the new MediaPlayer instance
    @objc public func add(_ playerId: Int) -> MediaPlayer {
        
        if (playerIds.index(forKey: playerId) != nil) {
            self.tracker.delegate?.warningDidOccur?("A player with the same id already exists.")
            return playerIds[playerId]!
        } else {
            let player = MediaPlayer(tracker: tracker)
            player.playerId = playerId
            playerIds[player.playerId] = player
            
            return player
        }

    }
    
    /// Remove a MediaPlayer by ID
    ///
    /// - Parameter playerId: the player identifier
    @objc public func remove(_ playerId: Int) {
        let player = playerIds[playerId]
        
        if let player = player {
           self.sendStops(player)
        }
        
        playerIds.removeValue(forKey: playerId)
    }
    
    /// Remove all MediaPlayer and stop every players
    @objc public func removeAll() {
        for (player) in self.playerIds.values {
            self.sendStops(player)
        }
        
        playerIds.removeAll(keepingCapacity: false)
    }
    
    
    /// Send Stop
    ///
    /// - Parameter player: send a stop action for all media attached to the player
    func sendStops(_ player: MediaPlayer) {
        for (video) in (player.videos.list.values) {
            if let timer = video.timer {
                if (timer.isValid) {
                    video.sendStop()
                }
            }
        }
        
        for (audio) in (player.audios.list.values) {
            if let timer = audio.timer {
                if (timer.isValid) {
                    audio.sendStop()
                }
            }
        }
        
        for (liveVideo) in (player.liveVideos.list.values) {
            if let timer = liveVideo.timer {
                if (timer.isValid) {
                    liveVideo.sendStop()
                }
            }
        }
        
        for (liveAudio) in (player.liveAudios.list.values) {
            if let timer = liveAudio.timer {
                if (timer.isValid) {
                    liveAudio.sendStop()
                }
            }
        }
        
        for (media) in (player.media.list.values) {
            if let timer = media.timer {
                if (timer.isValid) {
                    media.sendStop()
                }
            }
        }
        
        for (liveMedia) in (player.liveMedia.list.values) {
            if let timer = liveMedia.timer {
                if (timer.isValid) {
                    liveMedia.sendStop()
                }
            }
        }
    }
}
