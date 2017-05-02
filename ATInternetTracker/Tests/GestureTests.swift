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
//  TouchTests.swift
//  Tracker
//

import UIKit
import XCTest

class GestureTests: XCTestCase {

    lazy var gesture: Gesture = Gesture(tracker: Tracker())
    lazy var gestures: Gestures = Gestures(tracker: Tracker())
    
    override func setUp() {
        super.setUp()

        TechnicalContext.level2 = 0
        TechnicalContext.screenName = ""
    }
    
    func testInitGesture() {
        XCTAssertTrue(gesture.name == "", "Le nom du geste doit être vide")
        XCTAssertTrue(gesture.level2 == 0, "Le niveau 2 du geste doit etre égal à 0")
    }
    
    func testSetGesture() {
        gesture.name = "Back"
        gesture.setEvent()
        
        XCTAssertEqual(gesture.tracker.buffer.volatileParameters.count, 5, "Le nombre de paramètres volatiles doit être égal à 5")
        
        XCTAssert(gesture.tracker.buffer.volatileParameters["click"]!.key == "click", "Le premier paramètre doit être click")
        XCTAssert(gesture.tracker.buffer.volatileParameters["click"]!.values[0]() == "A", "La valeur du premier paramètre doit être A")
        
        XCTAssert(gesture.tracker.buffer.volatileParameters["type"]!.key == "type", "Le second paramètre doit être type")
        XCTAssert(gesture.tracker.buffer.volatileParameters["type"]!.values[0]() == "click", "La valeur du second paramètre doit être click")
        
        XCTAssert(gesture.tracker.buffer.volatileParameters["action"]!.key == "action", "Le troisième paramètre doit être action")
        XCTAssert(gesture.tracker.buffer.volatileParameters["action"]!.values[0]() == "A", "La valeur du troisième paramètre doit être A")
        
        XCTAssert(gesture.tracker.buffer.volatileParameters["p"]!.key == "p", "Le 4ème paramètre doit être p")
        XCTAssert(gesture.tracker.buffer.volatileParameters["p"]!.values[0]() == "Back", "La valeur du 4ème paramètre doit être Back")
    }
    
    func testSetGestureWithNameAndChapter() {
        gesture = gestures.add("Back", chapter1: "Sport")
        gesture.setEvent()
        
        XCTAssert(gesture.tracker.buffer.volatileParameters["p"]!.key == "p", "Le 4ème paramètre doit être p")
        XCTAssert(gesture.tracker.buffer.volatileParameters["p"]!.values[0]() == "Sport::Back", "La valeur du 4ème paramètre doit être Sport::Basket")
    }

    func testSetNavigation() {
        gesture.name = "Back"
        gesture.action = Gesture.GestureAction.navigate
        gesture.setEvent()
        
        XCTAssertEqual(gesture.tracker.buffer.volatileParameters.count, 5, "Le nombre de paramètres volatiles doit être égal à 5")
        
        XCTAssert(gesture.tracker.buffer.volatileParameters["click"]!.key == "click", "Le premier paramètre doit être click")
        XCTAssert(gesture.tracker.buffer.volatileParameters["click"]!.values[0]() == "N", "La valeur du premier paramètre doit être N")
        
        XCTAssert(gesture.tracker.buffer.volatileParameters["type"]!.key == "type", "Le second paramètre doit être type")
        XCTAssert(gesture.tracker.buffer.volatileParameters["type"]!.values[0]() == "click", "La valeur du second paramètre doit être click")
        
        XCTAssert(gesture.tracker.buffer.volatileParameters["action"]!.key == "action", "Le troisième paramètre doit être action")
        XCTAssert(gesture.tracker.buffer.volatileParameters["action"]!.values[0]() == "N", "La valeur du troisième paramètre doit être N")
        
        XCTAssert(gesture.tracker.buffer.volatileParameters["p"]!.key == "p", "Le 4ème paramètre doit être p")
        XCTAssert(gesture.tracker.buffer.volatileParameters["p"]!.values[0]() == "Back", "La valeur du 4ème paramètre doit être Back")
    }
    
    func testSetDownload() {
        gesture.name = "Download"
        gesture.action = Gesture.GestureAction.download
        gesture.setEvent()
        
        XCTAssertEqual(gesture.tracker.buffer.volatileParameters.count, 5, "Le nombre de paramètres volatiles doit être égal à 5")
        
        XCTAssert(gesture.tracker.buffer.volatileParameters["click"]!.key == "click", "Le premier paramètre doit être click")
        XCTAssert(gesture.tracker.buffer.volatileParameters["click"]!.values[0]() == "T", "La valeur du premier paramètre doit être T")
        
        XCTAssert(gesture.tracker.buffer.volatileParameters["type"]!.key == "type", "Le second paramètre doit être type")
        XCTAssert(gesture.tracker.buffer.volatileParameters["type"]!.values[0]() == "click", "La valeur du second paramètre doit être click")
        
        XCTAssert(gesture.tracker.buffer.volatileParameters["action"]!.key == "action", "Le troisième paramètre doit être action")
        XCTAssert(gesture.tracker.buffer.volatileParameters["action"]!.values[0]() == "T", "La valeur du troisième paramètre doit être T")
        
        XCTAssert(gesture.tracker.buffer.volatileParameters["p"]!.key == "p", "Le 4ème paramètre doit être p")
        XCTAssert(gesture.tracker.buffer.volatileParameters["p"]!.values[0]() == "Download", "La valeur du 4ème paramètre doit être Download")
    }
    
    func testSetTouch() {
        gesture.name = "Touch"
        gesture.action = Gesture.GestureAction.touch
        gesture.setEvent()
        
        XCTAssertEqual(gesture.tracker.buffer.volatileParameters.count, 5, "Le nombre de paramètres volatiles doit être égal à 5")
        
        XCTAssert(gesture.tracker.buffer.volatileParameters["click"]!.key == "click", "Le premier paramètre doit être click")
        XCTAssert(gesture.tracker.buffer.volatileParameters["click"]!.values[0]() == "A", "La valeur du premier paramètre doit être A")
        
        XCTAssert(gesture.tracker.buffer.volatileParameters["type"]!.key == "type", "Le second paramètre doit être type")
        XCTAssert(gesture.tracker.buffer.volatileParameters["type"]!.values[0]() == "click", "La valeur du second paramètre doit être click")
        
        XCTAssert(gesture.tracker.buffer.volatileParameters["action"]!.key == "action", "Le troisième paramètre doit être action")
        XCTAssert(gesture.tracker.buffer.volatileParameters["action"]!.values[0]() == "A", "La valeur du troisième paramètre doit être A")
        
        XCTAssert(gesture.tracker.buffer.volatileParameters["p"]!.key == "p", "Le 4ème paramètre doit être p")
        XCTAssert(gesture.tracker.buffer.volatileParameters["p"]!.values[0]() == "Touch", "La valeur du 4ème paramètre doit être Touch")
    }
    
    func testSetInternalSearch() {
        gesture.name = "Search"
        gesture.action = Gesture.GestureAction.search
        gesture.internalSearch = InternalSearch(keyword: "test", resultScreenNumber: 1)
        gesture.internalSearch?.resultPosition = 4
        gesture.setEvent()
        
        XCTAssertEqual(gesture.tracker.buffer.volatileParameters.count, 8, "Le nombre de paramètres volatiles doit être égal à 8")
        print(gesture.tracker.buffer.volatileParameters)
        
        XCTAssert(gesture.tracker.buffer.volatileParameters["mc"]!.key == "mc", "Le premier paramètre doit être mc (mot clef)")
        XCTAssert(gesture.tracker.buffer.volatileParameters["mc"]!.values[0]() == "test", "La valeur du premier paramètre doit être test")
        
        XCTAssert(gesture.tracker.buffer.volatileParameters["np"]!.key == "np", "Le premier paramètre doit être np (num page)")
        XCTAssert(gesture.tracker.buffer.volatileParameters["np"]!.values[0]() == "1", "La valeur du premier paramètre doit être 1")
        
        XCTAssert(gesture.tracker.buffer.volatileParameters["mcrg"]!.key == "mcrg", "Le premier paramètre doit être mcrg (mot clef rang)")
        XCTAssert(gesture.tracker.buffer.volatileParameters["mcrg"]!.values[0]() == "4", "La valeur du premier paramètre doit être 4")
        
        XCTAssert(gesture.tracker.buffer.volatileParameters["click"]!.key == "click", "Le premier paramètre doit être click")
        XCTAssert(gesture.tracker.buffer.volatileParameters["click"]!.values[0]() == "IS", "La valeur du premier paramètre doit être IS")
        
        XCTAssert(gesture.tracker.buffer.volatileParameters["type"]!.key == "type", "Le second paramètre doit être type")
        XCTAssert(gesture.tracker.buffer.volatileParameters["type"]!.values[0]() == "click", "La valeur du second paramètre doit être click")
        
        XCTAssert(gesture.tracker.buffer.volatileParameters["action"]!.key == "action", "Le troisième paramètre doit être action")
        XCTAssert(gesture.tracker.buffer.volatileParameters["action"]!.values[0]() == "IS", "La valeur du troisième paramètre doit être IS")
        
        XCTAssert(gesture.tracker.buffer.volatileParameters["p"]!.key == "p", "Le 4ème paramètre doit être p")
        XCTAssert(gesture.tracker.buffer.volatileParameters["p"]!.values[0]() == "Search", "La valeur du 4ème paramètre doit être Search")
    }
    
    
    func testSetExit() {
        gesture.name = "Exit"
        gesture.action = Gesture.GestureAction.exit
        gesture.setEvent()
        
        XCTAssertEqual(gesture.tracker.buffer.volatileParameters.count, 5, "Le nombre de paramètres volatiles doit être égal à 5")
        
        XCTAssert(gesture.tracker.buffer.volatileParameters["click"]!.key == "click", "Le premier paramètre doit être click")
        XCTAssert(gesture.tracker.buffer.volatileParameters["click"]!.values[0]() == "S", "La valeur du premier paramètre doit être S")
        
        XCTAssert(gesture.tracker.buffer.volatileParameters["type"]!.key == "type", "Le second paramètre doit être type")
        XCTAssert(gesture.tracker.buffer.volatileParameters["type"]!.values[0]() == "click", "La valeur du second paramètre doit être click")
        
        XCTAssert(gesture.tracker.buffer.volatileParameters["action"]!.key == "action", "Le troisième paramètre doit être action")
        XCTAssert(gesture.tracker.buffer.volatileParameters["action"]!.values[0]() == "S", "La valeur du troisième paramètre doit être S")
        
        XCTAssert(gesture.tracker.buffer.volatileParameters["p"]!.key == "p", "Le 4ème paramètre doit être p")
        XCTAssert(gesture.tracker.buffer.volatileParameters["p"]!.values[0]() == "Exit", "La valeur du 4ème paramètre doit être Exit")
    }
    
    func testAddGestureWithName() {
        gesture = gestures.add("Touch me")
        XCTAssert(gestures.tracker.businessObjects.count == 1, "Le nombre d'objet en attente doit être égale à 1")
        XCTAssert(gesture.name == "Touch me", "Le nom de l'écran doit etre égal à Touch me")
        XCTAssert((gestures.tracker.businessObjects[gesture.id] as! Gesture).name == "Touch me")
    }
    
    func testAddScreenWithNameAndLevel2() {
        gesture = gestures.add("Touch me, I want to fill your body")
        gesture.level2 = 1
        XCTAssert(gestures.tracker.businessObjects.count == 1, "Le nombre d'objet en attente doit être égale à 1")
        XCTAssert(gesture.name == "Touch me, I want to fill your body", "Le nom de l'écran doit etre égal à Touch me, I want to fill your body")
        XCTAssert(gesture.level2 == 1, "Le niveau 2 doit être égal à 1")
        XCTAssert((gestures.tracker.businessObjects[gesture.id] as! Gesture).name == "Touch me, I want to fill your body", "Le nom de l'écran doit etre égal à Touch me, I want to fill your body")
        XCTAssert((gestures.tracker.businessObjects[gesture.id] as! Gesture).level2 == 1, "Le niveau 2 doit être égal à 1")
    }
    
    func testContext() {
        let screen = gesture.tracker.screens.add("Home")
        screen.level2 = 2
        screen.sendView()
        
        gesture.name = "Touch"
        gesture.action = Gesture.GestureAction.touch
        gesture.setEvent()
        
        XCTAssertEqual(gesture.tracker.buffer.volatileParameters.count, 7, "Le nombre de paramètres volatiles doit être égal à 7")
        
        XCTAssert(gesture.tracker.buffer.volatileParameters["pclick"]!.key == "pclick", "Le premier paramètre doit être pclick")
        XCTAssert(gesture.tracker.buffer.volatileParameters["pclick"]!.values[0]() == "Home", "La valeur du premier paramètre doit être Home")
        
        XCTAssert(gesture.tracker.buffer.volatileParameters["s2click"]!.key == "s2click", "Le 2nd paramètre doit être s2click")
        XCTAssert(gesture.tracker.buffer.volatileParameters["s2click"]!.values[0]() == "2", "La valeur du 2nd paramètre doit être 2")
        
        XCTAssert(gesture.tracker.buffer.volatileParameters["click"]!.key == "click", "Le troisième paramètre doit être click")
        XCTAssert(gesture.tracker.buffer.volatileParameters["click"]!.values[0]() == "A", "La valeur du troisième paramètre doit être A")
        
        XCTAssert(gesture.tracker.buffer.volatileParameters["type"]!.key == "type", "Le 4ème paramètre doit être type")
        XCTAssert(gesture.tracker.buffer.volatileParameters["type"]!.values[0]() == "click", "La valeur du 4ème paramètre doit être click")
        
        XCTAssert(gesture.tracker.buffer.volatileParameters["action"]!.key == "action", "Le 5ème paramètre doit être action")
        XCTAssert(gesture.tracker.buffer.volatileParameters["action"]!.values[0]() == "A", "La valeur du 5ème paramètre doit être A")
        
        XCTAssert(gesture.tracker.buffer.volatileParameters["p"]!.key == "p", "Le 6ème paramètre doit être p")
        XCTAssert(gesture.tracker.buffer.volatileParameters["p"]!.values[0]() == "Touch", "La valeur du 6ème paramètre doit être Touch")
    }
}
