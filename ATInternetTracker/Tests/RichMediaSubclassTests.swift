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
//  RichMediaSubclassTests.swift
//  Tracker
//

import UIKit
import XCTest

class RichMediaSubclassTests: XCTestCase {

    let tracker = Tracker()
    
    var mediaPlayer: MediaPlayer?
    
    override func setUp() {
        mediaPlayer = tracker.mediaPlayers.add(1)
    }
    
    override func tearDown() {
        tracker.mediaPlayers.removeAll()
        TechnicalContext.screenName = ""
        TechnicalContext.level2 = 0
        tracker.buffer.volatileParameters.removeAll(keepingCapacity: false)
    }
    
    func testSetVideo() {
        let video: Video = Video(player: mediaPlayer!)
        
        video.isBuffering = false
        video.isEmbedded = false
        video.name = "Hey! Oh! Let's Go!"
        video.chapter1 = "The Ramones"
        video.chapter2 = "Blitzkrieg Bop"
        video.chapter3 = "1976"
        video.level2 = 666
        video.refreshDuration = 10
        video.duration = 7
        
        TechnicalContext.screenName = "rock"
        TechnicalContext.level2 = 13
        
        video.setEvent()
        
        var i = 0;
        
        XCTAssertEqual(video.player.tracker.buffer.volatileParameters.count, 11, "Le nombre de paramètres volatiles doit être égal à 11")
        
        XCTAssert(video.tracker.buffer.volatileParameters["p"]!.key == "p", "Le paramètre doit être p")
        XCTAssert(video.tracker.buffer.volatileParameters["p"]!.values[0]() == "The Ramones::Blitzkrieg Bop::1976::Hey! Oh! Let's Go!", "La valeur du paramètre doit être The Ramones::Blitzkrieg Bop::1976::Hey! Oh! Let's Go!")
        i += 1
        
        XCTAssert(video.tracker.buffer.volatileParameters["plyr"]!.key == "plyr", "Le paramètre doit être plyr")
        XCTAssert(video.tracker.buffer.volatileParameters["plyr"]!.values[0]() == "1", "La valeur du paramètre doit être 1")
        i += 1
        
        XCTAssert(video.tracker.buffer.volatileParameters["m6"]!.key == "m6", "Le paramètre doit être m6")
        XCTAssert(video.tracker.buffer.volatileParameters["m6"]!.values[0]() == "clip", "La valeur du paramètre doit être clip")
        i += 1
        
        XCTAssert(video.tracker.buffer.volatileParameters["a"]!.key == "a", "Le paramètre doit être a")
        XCTAssert(video.tracker.buffer.volatileParameters["a"]!.values[0]() == "play", "La valeur du paramètre doit être play")
        i += 1
        
        XCTAssert(video.tracker.buffer.volatileParameters["m5"]!.key == "m5", "Le paramètre doit être m5")
        XCTAssert(video.tracker.buffer.volatileParameters["m5"]!.values[0]() == "int", "La valeur du paramètre doit être int")
        i += 1
        
        XCTAssert(video.tracker.buffer.volatileParameters["s2"]!.key == "s2", "Le paramètre doit être s2")
        XCTAssert(video.tracker.buffer.volatileParameters["s2"]!.values[0]() == "666", "La valeur du paramètre doit être 666")
        i += 1
        
        XCTAssert(video.tracker.buffer.volatileParameters["buf"]!.key == "buf", "Le paramètre doit être buf")
        XCTAssert(video.tracker.buffer.volatileParameters["buf"]!.values[0]() == "0", "La valeur du paramètre doit être 0")
        i += 1
        
        XCTAssert(video.tracker.buffer.volatileParameters["prich"]!.key == "prich", "Le paramètre doit être prich")
        XCTAssert(video.tracker.buffer.volatileParameters["prich"]!.values[0]() == "rock", "La valeur du paramètre doit être rock")
        i += 1
        
        XCTAssert(video.tracker.buffer.volatileParameters["s2rich"]!.key == "s2rich", "Le paramètre doit être s2rich")
        XCTAssert(video.tracker.buffer.volatileParameters["s2rich"]!.values[0]() == "13", "La valeur du paramètre doit être 13")
        i += 1
        
        XCTAssert(video.tracker.buffer.volatileParameters["m1"]!.key == "m1", "Le paramètre doit être m1")
        XCTAssert(video.tracker.buffer.volatileParameters["m1"]!.values[0]() == "7", "La valeur du paramètre doit être 0")
        i += 1
        
        XCTAssert(video.tracker.buffer.volatileParameters["type"]!.key == "type", "Le paramètre doit être type")
        XCTAssert(video.tracker.buffer.volatileParameters["type"]!.values[0]() == "video", "La valeur du paramètre doit être video")
    }
    
    func testSetLiveVideo() {
        let video: LiveVideo = LiveVideo(player: mediaPlayer!)
        
        video.isBuffering = false
        video.isEmbedded = false
        video.name = "Hey! Oh! Let's Go!"
        video.chapter1 = "The Ramones"
        video.chapter2 = "Blitzkrieg Bop"
        video.chapter3 = "1976"
        video.level2 = 666
        video.refreshDuration = 10
        
        video.setEvent()
        
        var i = 0
        
        XCTAssertEqual(video.player.tracker.buffer.volatileParameters.count, 8, "Le nombre de paramètres volatiles doit être égal à 8")
        
        XCTAssert(video.tracker.buffer.volatileParameters["p"]!.key == "p", "Le paramètre doit être p")
        XCTAssert(video.tracker.buffer.volatileParameters["p"]!.values[0]() == "The Ramones::Blitzkrieg Bop::1976::Hey! Oh! Let's Go!", "La valeur du paramètre doit être The Ramones::Blitzkrieg Bop::1976::Hey! Oh! Let's Go!")
        i += 1
        
        XCTAssert(video.tracker.buffer.volatileParameters["plyr"]!.key == "plyr", "Le paramètre doit être plyr")
        XCTAssert(video.tracker.buffer.volatileParameters["plyr"]!.values[0]() == "1", "La valeur du paramètre doit être 1")
        i += 1
        
        XCTAssert(video.tracker.buffer.volatileParameters["m6"]!.key == "m6", "Le paramètre doit être m6")
        XCTAssert(video.tracker.buffer.volatileParameters["m6"]!.values[0]() == "live", "La valeur du paramètre doit être live")
        i += 1
        
        XCTAssert(video.tracker.buffer.volatileParameters["a"]!.key == "a", "Le paramètre doit être a")
        XCTAssert(video.tracker.buffer.volatileParameters["a"]!.values[0]() == "play", "La valeur du paramètre doit être play")
        i += 1
        
        XCTAssert(video.tracker.buffer.volatileParameters["m5"]!.key == "m5", "Le paramètre doit être m5")
        XCTAssert(video.tracker.buffer.volatileParameters["m5"]!.values[0]() == "int", "La valeur du paramètre doit être int")
        i += 1
        
        XCTAssert(video.tracker.buffer.volatileParameters["s2"]!.key == "s2", "Le paramètre doit être s2")
        XCTAssert(video.tracker.buffer.volatileParameters["s2"]!.values[0]() == "666", "La valeur du paramètre doit être 666")
        i += 1
        
        XCTAssert(video.tracker.buffer.volatileParameters["buf"]!.key == "buf", "Le paramètre doit être buf")
        XCTAssert(video.tracker.buffer.volatileParameters["buf"]!.values[0]() == "0", "La valeur du paramètre doit être 0")
        i += 1
        
        XCTAssert(video.tracker.buffer.volatileParameters["type"]!.key == "type", "Le paramètre doit être type")
        XCTAssert(video.tracker.buffer.volatileParameters["type"]!.values[0]() == "video", "La valeur du paramètre doit être video")
        
    }
    
    func testSetAudio() {
        let audio: Audio = Audio(player: mediaPlayer!)
        
        audio.isBuffering = false
        audio.isEmbedded = false
        audio.name = "Hey! Oh! Let's Go!"
        audio.chapter1 = "The Ramones"
        audio.chapter2 = "Blitzkrieg Bop"
        audio.chapter3 = "1976"
        audio.level2 = 666
        audio.refreshDuration = 10
        audio.duration = 7
        
        TechnicalContext.screenName = "rock"
        TechnicalContext.level2 = 13
        
        audio.setEvent()
        
        var i = 0;
        
        XCTAssertEqual(audio.player.tracker.buffer.volatileParameters.count, 11, "Le nombre de paramètres volatiles doit être égal à 11")
        
        XCTAssert(audio.tracker.buffer.volatileParameters["p"]!.key == "p", "Le paramètre doit être p")
        XCTAssert(audio.tracker.buffer.volatileParameters["p"]!.values[0]() == "The Ramones::Blitzkrieg Bop::1976::Hey! Oh! Let's Go!", "La valeur du paramètre doit être The Ramones::Blitzkrieg Bop::1976::Hey! Oh! Let's Go!")
        i += 1
        
        XCTAssert(audio.tracker.buffer.volatileParameters["plyr"]!.key == "plyr", "Le paramètre doit être plyr")
        XCTAssert(audio.tracker.buffer.volatileParameters["plyr"]!.values[0]() == "1", "La valeur du paramètre doit être 1")
        i += 1
        
        XCTAssert(audio.tracker.buffer.volatileParameters["m6"]!.key == "m6", "Le paramètre doit être m6")
        XCTAssert(audio.tracker.buffer.volatileParameters["m6"]!.values[0]() == "clip", "La valeur du paramètre doit être clip")
        i += 1
        
        XCTAssert(audio.tracker.buffer.volatileParameters["a"]!.key == "a", "Le paramètre doit être a")
        XCTAssert(audio.tracker.buffer.volatileParameters["a"]!.values[0]() == "play", "La valeur du paramètre doit être play")
        i += 1
        
        XCTAssert(audio.tracker.buffer.volatileParameters["m5"]!.key == "m5", "Le paramètre doit être m5")
        XCTAssert(audio.tracker.buffer.volatileParameters["m5"]!.values[0]() == "int", "La valeur du paramètre doit être int")
        i += 1
        
        XCTAssert(audio.tracker.buffer.volatileParameters["s2"]!.key == "s2", "Le paramètre doit être s2")
        XCTAssert(audio.tracker.buffer.volatileParameters["s2"]!.values[0]() == "666", "La valeur du paramètre doit être 666")
        i += 1
        
        XCTAssert(audio.tracker.buffer.volatileParameters["buf"]!.key == "buf", "Le paramètre doit être buf")
        XCTAssert(audio.tracker.buffer.volatileParameters["buf"]!.values[0]() == "0", "La valeur du paramètre doit être 0")
        i += 1
        
        XCTAssert(audio.tracker.buffer.volatileParameters["prich"]!.key == "prich", "Le paramètre doit être prich")
        XCTAssert(audio.tracker.buffer.volatileParameters["prich"]!.values[0]() == "rock", "La valeur du paramètre doit être rock")
        i += 1
        
        XCTAssert(audio.tracker.buffer.volatileParameters["s2rich"]!.key == "s2rich", "Le paramètre doit être s2rich")
        XCTAssert(audio.tracker.buffer.volatileParameters["s2rich"]!.values[0]() == "13", "La valeur du paramètre doit être 13")
        i += 1
        
        XCTAssert(audio.tracker.buffer.volatileParameters["m1"]!.key == "m1", "Le paramètre doit être m1")
        XCTAssert(audio.tracker.buffer.volatileParameters["m1"]!.values[0]() == "7", "La valeur du paramètre doit être 0")
        i += 1
        
        XCTAssert(audio.tracker.buffer.volatileParameters["type"]!.key == "type", "Le paramètre doit être type")
        XCTAssert(audio.tracker.buffer.volatileParameters["type"]!.values[0]() == "audio", "La valeur du paramètre doit être audio")
    }
    
    func testSetLiveAudio() {
        let audio: LiveAudio = LiveAudio(player: mediaPlayer!)
        
        audio.isBuffering = false
        audio.isEmbedded = false
        audio.name = "Hey! Oh! Let's Go!"
        audio.chapter1 = "The Ramones"
        audio.chapter2 = "Blitzkrieg Bop"
        audio.chapter3 = "1976"
        audio.level2 = 666
        audio.refreshDuration = 10
        
        audio.setEvent()
        
        var i = 0
        
        XCTAssertEqual(audio.player.tracker.buffer.volatileParameters.count, 8, "Le nombre de paramètres volatiles doit être égal à 8")
        
        XCTAssert(audio.tracker.buffer.volatileParameters["p"]!.key == "p", "Le paramètre doit être p")
        XCTAssert(audio.tracker.buffer.volatileParameters["p"]!.values[0]() == "The Ramones::Blitzkrieg Bop::1976::Hey! Oh! Let's Go!", "La valeur du paramètre doit être The Ramones::Blitzkrieg Bop::1976::Hey! Oh! Let's Go!")
        i += 1
        
        XCTAssert(audio.tracker.buffer.volatileParameters["plyr"]!.key == "plyr", "Le paramètre doit être plyr")
        XCTAssert(audio.tracker.buffer.volatileParameters["plyr"]!.values[0]() == "1", "La valeur du paramètre doit être 1")
        i += 1
        
        XCTAssert(audio.tracker.buffer.volatileParameters["m6"]!.key == "m6", "Le paramètre doit être m6")
        XCTAssert(audio.tracker.buffer.volatileParameters["m6"]!.values[0]() == "live", "La valeur du paramètre doit être live")
        i += 1
        
        XCTAssert(audio.tracker.buffer.volatileParameters["a"]!.key == "a", "Le paramètre doit être a")
        XCTAssert(audio.tracker.buffer.volatileParameters["a"]!.values[0]() == "play", "La valeur du paramètre doit être play")
        i += 1
        
        XCTAssert(audio.tracker.buffer.volatileParameters["m5"]!.key == "m5", "Le paramètre doit être m5")
        XCTAssert(audio.tracker.buffer.volatileParameters["m5"]!.values[0]() == "int", "La valeur du paramètre doit être int")
        i += 1
        
        XCTAssert(audio.tracker.buffer.volatileParameters["s2"]!.key == "s2", "Le paramètre doit être s2")
        XCTAssert(audio.tracker.buffer.volatileParameters["s2"]!.values[0]() == "666", "La valeur du paramètre doit être 666")
        i += 1
        
        XCTAssert(audio.tracker.buffer.volatileParameters["buf"]!.key == "buf", "Le paramètre doit être buf")
        XCTAssert(audio.tracker.buffer.volatileParameters["buf"]!.values[0]() == "0", "La valeur du paramètre doit être 0")
        i += 1
        
        XCTAssert(audio.tracker.buffer.volatileParameters["type"]!.key == "type", "Le paramètre doit être type")
        XCTAssert(audio.tracker.buffer.volatileParameters["type"]!.values[0]() == "audio", "La valeur du paramètre doit être audio")
    }
}
