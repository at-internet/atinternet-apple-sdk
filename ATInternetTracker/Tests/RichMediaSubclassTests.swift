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
        TechnicalContext.level2 = -1
        tracker.buffer.volatileParameters.removeAll(keepingCapacity: false)
    }
    
    func testSetVideo() {
        let video: Video = Video(tracker: mediaPlayer!.tracker, playerId: mediaPlayer!.playerId)
        
        video.isEmbedded = false
        video.name = "Hey! Oh! Let's Go!"
        video.chapter1 = "The Ramones"
        video.chapter2 = "Blitzkrieg Bop"
        video.chapter3 = "1976"
        video.level2 = 666
        video.refreshDuration = 10
        video.duration = 7
        
        video.setParams()
        
        var i = 0;
        
        XCTAssertEqual(tracker.buffer.volatileParameters.count, 7, "Le nombre de paramètres volatiles doit être égal à 7")
        
        XCTAssert(video.tracker.buffer.volatileParameters["p"]!.key == "p", "Le paramètre doit être p")
        XCTAssert(video.tracker.buffer.volatileParameters["p"]!.values[0]() == "The Ramones::Blitzkrieg Bop::1976::Hey! Oh! Let's Go!", "La valeur du paramètre doit être The Ramones::Blitzkrieg Bop::1976::Hey! Oh! Let's Go!")
        i += 1
        
        XCTAssert(video.tracker.buffer.volatileParameters["plyr"]!.key == "plyr", "Le paramètre doit être plyr")
        XCTAssert(video.tracker.buffer.volatileParameters["plyr"]!.values[0]() == "1", "La valeur du paramètre doit être 1")
        i += 1
        
        XCTAssert(video.tracker.buffer.volatileParameters["m6"]!.key == "m6", "Le paramètre doit être m6")
        XCTAssert(video.tracker.buffer.volatileParameters["m6"]!.values[0]() == "clip", "La valeur du paramètre doit être clip")
        i += 1
        
        XCTAssert(video.tracker.buffer.volatileParameters["m5"]!.key == "m5", "Le paramètre doit être m5")
        XCTAssert(video.tracker.buffer.volatileParameters["m5"]!.values[0]() == "int", "La valeur du paramètre doit être int")
        i += 1
        
        XCTAssert(video.tracker.buffer.volatileParameters["s2"]!.key == "s2", "Le paramètre doit être s2")
        XCTAssert(video.tracker.buffer.volatileParameters["s2"]!.values[0]() == "666", "La valeur du paramètre doit être 666")
        i += 1

        
        XCTAssert(video.tracker.buffer.volatileParameters["m1"]!.key == "m1", "Le paramètre doit être m1")
        XCTAssert(video.tracker.buffer.volatileParameters["m1"]!.values[0]() == "7", "La valeur du paramètre doit être 0")
        i += 1
        
        XCTAssert(video.tracker.buffer.volatileParameters["type"]!.key == "type", "Le paramètre doit être type")
        XCTAssert(video.tracker.buffer.volatileParameters["type"]!.values[0]() == "video", "La valeur du paramètre doit être video")
    }
    
    func testSetLiveVideo() {
        let video: LiveVideo = LiveVideo(tracker: mediaPlayer!.tracker, playerId: mediaPlayer!.playerId)
        
        video.isEmbedded = false
        video.name = "Hey! Oh! Let's Go!"
        video.chapter1 = "The Ramones"
        video.chapter2 = "Blitzkrieg Bop"
        video.chapter3 = "1976"
        video.level2 = 666
        video.refreshDuration = 10
        
        video.setParams()
        
        var i = 0
        
        XCTAssertEqual(tracker.buffer.volatileParameters.count, 6, "Le nombre de paramètres volatiles doit être égal à 6")
        
        XCTAssert(video.tracker.buffer.volatileParameters["p"]!.key == "p", "Le paramètre doit être p")
        XCTAssert(video.tracker.buffer.volatileParameters["p"]!.values[0]() == "The Ramones::Blitzkrieg Bop::1976::Hey! Oh! Let's Go!", "La valeur du paramètre doit être The Ramones::Blitzkrieg Bop::1976::Hey! Oh! Let's Go!")
        i += 1
        
        XCTAssert(video.tracker.buffer.volatileParameters["plyr"]!.key == "plyr", "Le paramètre doit être plyr")
        XCTAssert(video.tracker.buffer.volatileParameters["plyr"]!.values[0]() == "1", "La valeur du paramètre doit être 1")
        i += 1
        
        XCTAssert(video.tracker.buffer.volatileParameters["m6"]!.key == "m6", "Le paramètre doit être m6")
        XCTAssert(video.tracker.buffer.volatileParameters["m6"]!.values[0]() == "live", "La valeur du paramètre doit être live")
        i += 1
        
        XCTAssert(video.tracker.buffer.volatileParameters["m5"]!.key == "m5", "Le paramètre doit être m5")
        XCTAssert(video.tracker.buffer.volatileParameters["m5"]!.values[0]() == "int", "La valeur du paramètre doit être int")
        i += 1
        
        XCTAssert(video.tracker.buffer.volatileParameters["s2"]!.key == "s2", "Le paramètre doit être s2")
        XCTAssert(video.tracker.buffer.volatileParameters["s2"]!.values[0]() == "666", "La valeur du paramètre doit être 666")
        i += 1
        
        XCTAssert(video.tracker.buffer.volatileParameters["type"]!.key == "type", "Le paramètre doit être type")
        XCTAssert(video.tracker.buffer.volatileParameters["type"]!.values[0]() == "video", "La valeur du paramètre doit être video")
        
    }
    
    func testSetAudio() {
        let audio: Audio = Audio(tracker: mediaPlayer!.tracker, playerId: mediaPlayer!.playerId)
        
        audio.isEmbedded = false
        audio.name = "Hey! Oh! Let's Go!"
        audio.chapter1 = "The Ramones"
        audio.chapter2 = "Blitzkrieg Bop"
        audio.chapter3 = "1976"
        audio.level2 = 666
        audio.refreshDuration = 10
        audio.duration = 7
        
        audio.setParams()
        
        var i = 0;
        
        XCTAssertEqual(tracker.buffer.volatileParameters.count, 7, "Le nombre de paramètres volatiles doit être égal à 7")
        
        XCTAssert(audio.tracker.buffer.volatileParameters["p"]!.key == "p", "Le paramètre doit être p")
        XCTAssert(audio.tracker.buffer.volatileParameters["p"]!.values[0]() == "The Ramones::Blitzkrieg Bop::1976::Hey! Oh! Let's Go!", "La valeur du paramètre doit être The Ramones::Blitzkrieg Bop::1976::Hey! Oh! Let's Go!")
        i += 1
        
        XCTAssert(audio.tracker.buffer.volatileParameters["plyr"]!.key == "plyr", "Le paramètre doit être plyr")
        XCTAssert(audio.tracker.buffer.volatileParameters["plyr"]!.values[0]() == "1", "La valeur du paramètre doit être 1")
        i += 1
        
        XCTAssert(audio.tracker.buffer.volatileParameters["m6"]!.key == "m6", "Le paramètre doit être m6")
        XCTAssert(audio.tracker.buffer.volatileParameters["m6"]!.values[0]() == "clip", "La valeur du paramètre doit être clip")
        i += 1
        
        XCTAssert(audio.tracker.buffer.volatileParameters["m5"]!.key == "m5", "Le paramètre doit être m5")
        XCTAssert(audio.tracker.buffer.volatileParameters["m5"]!.values[0]() == "int", "La valeur du paramètre doit être int")
        i += 1
        
        XCTAssert(audio.tracker.buffer.volatileParameters["s2"]!.key == "s2", "Le paramètre doit être s2")
        XCTAssert(audio.tracker.buffer.volatileParameters["s2"]!.values[0]() == "666", "La valeur du paramètre doit être 666")
        i += 1
        
        XCTAssert(audio.tracker.buffer.volatileParameters["m1"]!.key == "m1", "Le paramètre doit être m1")
        XCTAssert(audio.tracker.buffer.volatileParameters["m1"]!.values[0]() == "7", "La valeur du paramètre doit être 0")
        i += 1
        
        XCTAssert(audio.tracker.buffer.volatileParameters["type"]!.key == "type", "Le paramètre doit être type")
        XCTAssert(audio.tracker.buffer.volatileParameters["type"]!.values[0]() == "audio", "La valeur du paramètre doit être audio")
    }
    
    func testSetLiveAudio() {
        let audio: LiveAudio = LiveAudio(tracker: mediaPlayer!.tracker, playerId: mediaPlayer!.playerId)
        
        audio.isEmbedded = false
        audio.name = "Hey! Oh! Let's Go!"
        audio.chapter1 = "The Ramones"
        audio.chapter2 = "Blitzkrieg Bop"
        audio.chapter3 = "1976"
        audio.level2 = 666
        audio.refreshDuration = 10
        
        audio.setParams()
        
        var i = 0
        
        XCTAssertEqual(tracker.buffer.volatileParameters.count, 6, "Le nombre de paramètres volatiles doit être égal à 6")
        
        XCTAssert(audio.tracker.buffer.volatileParameters["p"]!.key == "p", "Le paramètre doit être p")
        XCTAssert(audio.tracker.buffer.volatileParameters["p"]!.values[0]() == "The Ramones::Blitzkrieg Bop::1976::Hey! Oh! Let's Go!", "La valeur du paramètre doit être The Ramones::Blitzkrieg Bop::1976::Hey! Oh! Let's Go!")
        i += 1
        
        XCTAssert(audio.tracker.buffer.volatileParameters["plyr"]!.key == "plyr", "Le paramètre doit être plyr")
        XCTAssert(audio.tracker.buffer.volatileParameters["plyr"]!.values[0]() == "1", "La valeur du paramètre doit être 1")
        i += 1
        
        XCTAssert(audio.tracker.buffer.volatileParameters["m6"]!.key == "m6", "Le paramètre doit être m6")
        XCTAssert(audio.tracker.buffer.volatileParameters["m6"]!.values[0]() == "live", "La valeur du paramètre doit être live")
        i += 1
        
        XCTAssert(audio.tracker.buffer.volatileParameters["m5"]!.key == "m5", "Le paramètre doit être m5")
        XCTAssert(audio.tracker.buffer.volatileParameters["m5"]!.values[0]() == "int", "La valeur du paramètre doit être int")
        i += 1
        
        XCTAssert(audio.tracker.buffer.volatileParameters["s2"]!.key == "s2", "Le paramètre doit être s2")
        XCTAssert(audio.tracker.buffer.volatileParameters["s2"]!.values[0]() == "666", "La valeur du paramètre doit être 666")
        i += 1
        
        XCTAssert(audio.tracker.buffer.volatileParameters["type"]!.key == "type", "Le paramètre doit être type")
        XCTAssert(audio.tracker.buffer.volatileParameters["type"]!.values[0]() == "audio", "La valeur du paramètre doit être audio")
    }
    
    func testSetMedium() {
        let medium: Medium = Medium(tracker: mediaPlayer!.tracker, playerId: mediaPlayer!.playerId)
        
        medium.isEmbedded = false
        medium.mediaLabel = "Hey! Oh! Let's Go!"
        medium.mediaTheme1 = "The Ramones"
        medium.mediaTheme2 = "Blitzkrieg Bop"
        medium.mediaTheme3 = "1976"
        medium.mediaLevel2 = 666
        medium.refreshDuration = 10
        medium.duration = 7
        medium.type = "free"
        
        medium.setParams()
        
        var i = 0;
        
        XCTAssertEqual(tracker.buffer.volatileParameters.count, 7, "Le nombre de paramètres volatiles doit être égal à 7")
        
        XCTAssert(medium.tracker.buffer.volatileParameters["p"]!.key == "p", "Le paramètre doit être p")
        XCTAssert(medium.tracker.buffer.volatileParameters["p"]!.values[0]() == "The Ramones::Blitzkrieg Bop::1976::Hey! Oh! Let's Go!", "La valeur du paramètre doit être The Ramones::Blitzkrieg Bop::1976::Hey! Oh! Let's Go!")
        i += 1
        
        XCTAssert(medium.tracker.buffer.volatileParameters["plyr"]!.key == "plyr", "Le paramètre doit être plyr")
        XCTAssert(medium.tracker.buffer.volatileParameters["plyr"]!.values[0]() == "1", "La valeur du paramètre doit être 1")
        i += 1
        
        XCTAssert(medium.tracker.buffer.volatileParameters["m6"]!.key == "m6", "Le paramètre doit être m6")
        XCTAssert(medium.tracker.buffer.volatileParameters["m6"]!.values[0]() == "clip", "La valeur du paramètre doit être clip")
        i += 1
        
        XCTAssert(medium.tracker.buffer.volatileParameters["m5"]!.key == "m5", "Le paramètre doit être m5")
        XCTAssert(medium.tracker.buffer.volatileParameters["m5"]!.values[0]() == "int", "La valeur du paramètre doit être int")
        i += 1
        
        XCTAssert(medium.tracker.buffer.volatileParameters["s2"]!.key == "s2", "Le paramètre doit être s2")
        XCTAssert(medium.tracker.buffer.volatileParameters["s2"]!.values[0]() == "666", "La valeur du paramètre doit être 666")
        i += 1
        
        XCTAssert(medium.tracker.buffer.volatileParameters["m1"]!.key == "m1", "Le paramètre doit être m1")
        XCTAssert(medium.tracker.buffer.volatileParameters["m1"]!.values[0]() == "7", "La valeur du paramètre doit être 0")
        i += 1
        
        XCTAssert(medium.tracker.buffer.volatileParameters["type"]!.key == "type", "Le paramètre doit être type")
        XCTAssert(medium.tracker.buffer.volatileParameters["type"]!.values[0]() == "free", "La valeur du paramètre doit être audio")
    }
    
    func testSetLiveMedium() {
        let medium: LiveMedium = LiveMedium(tracker: mediaPlayer!.tracker, playerId: mediaPlayer!.playerId)
        
        medium.isEmbedded = false
        medium.mediaLabel = "Hey! Oh! Let's Go!"
        medium.mediaTheme1 = "The Ramones"
        medium.mediaTheme2 = "Blitzkrieg Bop"
        medium.mediaTheme3 = "1976"
        medium.mediaLevel2 = 666
        medium.refreshDuration = 10
        medium.type = "free"
        
        medium.setParams()
        
        var i = 0
        
        XCTAssertEqual(tracker.buffer.volatileParameters.count, 6, "Le nombre de paramètres volatiles doit être égal à 6")
        
        XCTAssert(medium.tracker.buffer.volatileParameters["p"]!.key == "p", "Le paramètre doit être p")
        XCTAssert(medium.tracker.buffer.volatileParameters["p"]!.values[0]() == "The Ramones::Blitzkrieg Bop::1976::Hey! Oh! Let's Go!", "La valeur du paramètre doit être The Ramones::Blitzkrieg Bop::1976::Hey! Oh! Let's Go!")
        i += 1
        
        XCTAssert(medium.tracker.buffer.volatileParameters["plyr"]!.key == "plyr", "Le paramètre doit être plyr")
        XCTAssert(medium.tracker.buffer.volatileParameters["plyr"]!.values[0]() == "1", "La valeur du paramètre doit être 1")
        i += 1
        
        XCTAssert(medium.tracker.buffer.volatileParameters["m6"]!.key == "m6", "Le paramètre doit être m6")
        XCTAssert(medium.tracker.buffer.volatileParameters["m6"]!.values[0]() == "live", "La valeur du paramètre doit être live")
        i += 1
        
        XCTAssert(medium.tracker.buffer.volatileParameters["m5"]!.key == "m5", "Le paramètre doit être m5")
        XCTAssert(medium.tracker.buffer.volatileParameters["m5"]!.values[0]() == "int", "La valeur du paramètre doit être int")
        i += 1
        
        XCTAssert(medium.tracker.buffer.volatileParameters["s2"]!.key == "s2", "Le paramètre doit être s2")
        XCTAssert(medium.tracker.buffer.volatileParameters["s2"]!.values[0]() == "666", "La valeur du paramètre doit être 666")
        i += 1
        
        XCTAssert(medium.tracker.buffer.volatileParameters["type"]!.key == "type", "Le paramètre doit être type")
        XCTAssert(medium.tracker.buffer.volatileParameters["type"]!.values[0]() == "free", "La valeur du paramètre doit être audio")
    }
}
