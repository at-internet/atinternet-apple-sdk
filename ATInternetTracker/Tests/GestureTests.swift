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
        
        XCTAssert(gesture.tracker.buffer.volatileParameters[0].key == "click", "Le premier paramètre doit être click")
        XCTAssert(gesture.tracker.buffer.volatileParameters[0].value() == "A", "La valeur du premier paramètre doit être A")
        
        XCTAssert(gesture.tracker.buffer.volatileParameters[1].key == "type", "Le second paramètre doit être type")
        XCTAssert(gesture.tracker.buffer.volatileParameters[1].value() == "click", "La valeur du second paramètre doit être click")
        
        XCTAssert(gesture.tracker.buffer.volatileParameters[2].key == "action", "Le troisième paramètre doit être action")
        XCTAssert(gesture.tracker.buffer.volatileParameters[2].value() == "A", "La valeur du troisième paramètre doit être A")
        
        XCTAssert(gesture.tracker.buffer.volatileParameters[3].key == "p", "Le 4ème paramètre doit être p")
        XCTAssert(gesture.tracker.buffer.volatileParameters[3].value() == "Back", "La valeur du 4ème paramètre doit être Back")
    }
    
    func testSetGestureWithNameAndChapter() {
        gesture = gestures.add("Back", chapter1: "Sport")
        gesture.setEvent()
        
        XCTAssert(gesture.tracker.buffer.volatileParameters[3].key == "p", "Le 4ème paramètre doit être p")
        XCTAssert(gesture.tracker.buffer.volatileParameters[3].value() == "Sport::Back", "La valeur du 4ème paramètre doit être Sport::Basket")
    }

    func testSetNavigation() {
        gesture.name = "Back"
        gesture.action = Gesture.GestureAction.Navigate
        gesture.setEvent()
        
        XCTAssertEqual(gesture.tracker.buffer.volatileParameters.count, 5, "Le nombre de paramètres volatiles doit être égal à 5")
        
        XCTAssert(gesture.tracker.buffer.volatileParameters[0].key == "click", "Le premier paramètre doit être click")
        XCTAssert(gesture.tracker.buffer.volatileParameters[0].value() == "N", "La valeur du premier paramètre doit être N")
        
        XCTAssert(gesture.tracker.buffer.volatileParameters[1].key == "type", "Le second paramètre doit être type")
        XCTAssert(gesture.tracker.buffer.volatileParameters[1].value() == "click", "La valeur du second paramètre doit être click")
        
        XCTAssert(gesture.tracker.buffer.volatileParameters[2].key == "action", "Le troisième paramètre doit être action")
        XCTAssert(gesture.tracker.buffer.volatileParameters[2].value() == "N", "La valeur du troisième paramètre doit être N")
        
        XCTAssert(gesture.tracker.buffer.volatileParameters[3].key == "p", "Le 4ème paramètre doit être p")
        XCTAssert(gesture.tracker.buffer.volatileParameters[3].value() == "Back", "La valeur du 4ème paramètre doit être Back")
    }
    
    func testSetDownload() {
        gesture.name = "Download"
        gesture.action = Gesture.GestureAction.Download
        gesture.setEvent()
        
        XCTAssertEqual(gesture.tracker.buffer.volatileParameters.count, 5, "Le nombre de paramètres volatiles doit être égal à 5")
        
        XCTAssert(gesture.tracker.buffer.volatileParameters[0].key == "click", "Le premier paramètre doit être click")
        XCTAssert(gesture.tracker.buffer.volatileParameters[0].value() == "T", "La valeur du premier paramètre doit être T")
        
        XCTAssert(gesture.tracker.buffer.volatileParameters[1].key == "type", "Le second paramètre doit être type")
        XCTAssert(gesture.tracker.buffer.volatileParameters[1].value() == "click", "La valeur du second paramètre doit être click")
        
        XCTAssert(gesture.tracker.buffer.volatileParameters[2].key == "action", "Le troisième paramètre doit être action")
        XCTAssert(gesture.tracker.buffer.volatileParameters[2].value() == "T", "La valeur du troisième paramètre doit être T")
        
        XCTAssert(gesture.tracker.buffer.volatileParameters[3].key == "p", "Le 4ème paramètre doit être p")
        XCTAssert(gesture.tracker.buffer.volatileParameters[3].value() == "Download", "La valeur du 4ème paramètre doit être Download")
    }
    
    func testSetTouch() {
        gesture.name = "Touch"
        gesture.action = Gesture.GestureAction.Touch
        gesture.setEvent()
        
        XCTAssertEqual(gesture.tracker.buffer.volatileParameters.count, 5, "Le nombre de paramètres volatiles doit être égal à 5")
        
        XCTAssert(gesture.tracker.buffer.volatileParameters[0].key == "click", "Le premier paramètre doit être click")
        XCTAssert(gesture.tracker.buffer.volatileParameters[0].value() == "A", "La valeur du premier paramètre doit être A")
        
        XCTAssert(gesture.tracker.buffer.volatileParameters[1].key == "type", "Le second paramètre doit être type")
        XCTAssert(gesture.tracker.buffer.volatileParameters[1].value() == "click", "La valeur du second paramètre doit être click")
        
        XCTAssert(gesture.tracker.buffer.volatileParameters[2].key == "action", "Le troisième paramètre doit être action")
        XCTAssert(gesture.tracker.buffer.volatileParameters[2].value() == "A", "La valeur du troisième paramètre doit être A")
        
        XCTAssert(gesture.tracker.buffer.volatileParameters[3].key == "p", "Le 4ème paramètre doit être p")
        XCTAssert(gesture.tracker.buffer.volatileParameters[3].value() == "Touch", "La valeur du 4ème paramètre doit être Touch")
    }
    
    func testSetExit() {
        gesture.name = "Exit"
        gesture.action = Gesture.GestureAction.Exit
        gesture.setEvent()
        
        XCTAssertEqual(gesture.tracker.buffer.volatileParameters.count, 5, "Le nombre de paramètres volatiles doit être égal à 5")
        
        XCTAssert(gesture.tracker.buffer.volatileParameters[0].key == "click", "Le premier paramètre doit être click")
        XCTAssert(gesture.tracker.buffer.volatileParameters[0].value() == "S", "La valeur du premier paramètre doit être S")
        
        XCTAssert(gesture.tracker.buffer.volatileParameters[1].key == "type", "Le second paramètre doit être type")
        XCTAssert(gesture.tracker.buffer.volatileParameters[1].value() == "click", "La valeur du second paramètre doit être click")
        
        XCTAssert(gesture.tracker.buffer.volatileParameters[2].key == "action", "Le troisième paramètre doit être action")
        XCTAssert(gesture.tracker.buffer.volatileParameters[2].value() == "S", "La valeur du troisième paramètre doit être S")
        
        XCTAssert(gesture.tracker.buffer.volatileParameters[3].key == "p", "Le 4ème paramètre doit être p")
        XCTAssert(gesture.tracker.buffer.volatileParameters[3].value() == "Exit", "La valeur du 4ème paramètre doit être Exit")
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
        gesture.action = Gesture.GestureAction.Touch
        gesture.setEvent()
        
        XCTAssertEqual(gesture.tracker.buffer.volatileParameters.count, 7, "Le nombre de paramètres volatiles doit être égal à 7")
        
        XCTAssert(gesture.tracker.buffer.volatileParameters[0].key == "pclick", "Le premier paramètre doit être pclick")
        XCTAssert(gesture.tracker.buffer.volatileParameters[0].value() == "Home", "La valeur du premier paramètre doit être Home")
        
        XCTAssert(gesture.tracker.buffer.volatileParameters[1].key == "s2click", "Le 2nd paramètre doit être s2click")
        XCTAssert(gesture.tracker.buffer.volatileParameters[1].value() == "2", "La valeur du 2nd paramètre doit être 2")
        
        XCTAssert(gesture.tracker.buffer.volatileParameters[2].key == "click", "Le troisième paramètre doit être click")
        XCTAssert(gesture.tracker.buffer.volatileParameters[2].value() == "A", "La valeur du troisième paramètre doit être A")
        
        XCTAssert(gesture.tracker.buffer.volatileParameters[3].key == "type", "Le 4ème paramètre doit être type")
        XCTAssert(gesture.tracker.buffer.volatileParameters[3].value() == "click", "La valeur du 4ème paramètre doit être click")
        
        XCTAssert(gesture.tracker.buffer.volatileParameters[4].key == "action", "Le 5ème paramètre doit être action")
        XCTAssert(gesture.tracker.buffer.volatileParameters[4].value() == "A", "La valeur du 5ème paramètre doit être A")
        
        XCTAssert(gesture.tracker.buffer.volatileParameters[5].key == "p", "Le 6ème paramètre doit être p")
        XCTAssert(gesture.tracker.buffer.volatileParameters[5].value() == "Touch", "La valeur du 6ème paramètre doit être Touch")
    }
}
