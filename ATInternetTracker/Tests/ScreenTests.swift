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
//  ScreenTests.swift
//  Tracker
//

import UIKit
import XCTest
@testable import ATInternetTracker

class ScreenTests: XCTestCase {

    lazy var screen: Screen = Screen(tracker: Tracker())
    lazy var screens: Screens = Screens(tracker: Tracker())
    
    lazy var dynamicScreen: DynamicScreen = DynamicScreen(tracker: Tracker())
    lazy var dynamicScreens: DynamicScreens = DynamicScreens(tracker: Tracker())
    
    let curDate = Date()
    let dateFormatter: DateFormatter = DateFormatter()
    
    func testInitScreen() {
        XCTAssertTrue(screen.name == "", "Le nom de l'écran doit être vide")
        XCTAssertTrue(screen.level2 == -1, "Le niveau 2 de l'écran doit etre égal à -1")
    }
    
    func testSetScreen() {
        screen.name = "Home"
        screen.setParams()
        
        XCTAssertEqual(screen.tracker.buffer.volatileParameters.count, 1, "Le nombre de paramètres volatiles doit être égal à 1")
        
        XCTAssert(screen.tracker.buffer.volatileParameters["p"]!.key == "p", "Le troisième paramètre doit être p")
        XCTAssert(screen.tracker.buffer.volatileParameters["p"]!.values[0]() == "Home", "La valeur du troisième paramètre doit être Home")
    }
    
    func testSetScreenWithNameAndChapter() {
        screen = screens.add("Basket", chapter1: "Sport")
        screen.setParams()
        
        XCTAssert(screen.tracker.buffer.volatileParameters["p"]!.key == "p", "Le troisième paramètre doit être p")
        XCTAssert(screen.tracker.buffer.volatileParameters["p"]!.values[0]() == "Sport::Basket", "La valeur du troisième paramètre doit être Sport::Basket")
    }
    
    func testAddScreen() {
        screen = screens.add()
        XCTAssert(screens.tracker.businessObjects.count == 1, "Le nombre d'objet en attente doit être égale à 1")
        XCTAssert(screen.name == "", "Le nom de l'écran doit etre vide")
        XCTAssert((screens.tracker.businessObjects[screen.id] as! Screen).name == "", "Le nom de l'écran doit etre vide")
    }
    
    func testAddScreenWithName() {
        screen = screens.add("Home")
        XCTAssert(screens.tracker.businessObjects.count == 1, "Le nombre d'objet en attente doit être égale à 1")
        XCTAssert(screen.name == "Home", "Le nom de l'écran doit etre égal à Home")
        XCTAssert((screens.tracker.businessObjects[screen.id] as! Screen).name == "Home", "Le nom de l'écran doit etre égal à Home")
    }
    
    func testAddScreenWithNameAndLevel2() {
        screen = screens.add("Home")
        screen.level2 = 1
        XCTAssert(screens.tracker.businessObjects.count == 1, "Le nombre d'objet en attente doit être égale à 1")
        XCTAssert(screen.name == "Home", "Le nom de l'écran doit etre égal à Home")
        XCTAssert(screen.level2 == 1, "Le niveau 2 doit être égal à 1")
        XCTAssert((screens.tracker.businessObjects[screen.id] as! Screen).name == "Home", "Le nom de l'écran doit etre égal à Home")
        XCTAssert((screens.tracker.businessObjects[screen.id] as! Screen).level2 == 1, "Le niveau 2 doit être égal à 1")
    }
    
    func testSetDynamicScreen() {
        dateFormatter.dateFormat = "YYYYMMddHHmm"
        
        dynamicScreen.screenId = "123"
        dynamicScreen.update = curDate;
        dynamicScreen.name = "HomeDyn"
        dynamicScreen.chapter1 = "chap1"
        dynamicScreen.chapter2 = "chap2"
        dynamicScreen.chapter3 = "chap3"
        
        dynamicScreen.setParams()
        
        XCTAssertEqual(dynamicScreen.tracker.buffer.volatileParameters.count, 4, "Le nombre de paramètres volatiles doit être égal à 4")
        
        XCTAssert(dynamicScreen.tracker.buffer.volatileParameters["pchap"]!.key == "pchap", "Le paramètre doit être pchap")
        print(dynamicScreen.tracker.buffer.volatileParameters["pchap"]!.values[0]())
        XCTAssert(dynamicScreen.tracker.buffer.volatileParameters["pchap"]!.values[0]() == "chap1::chap2::chap3", "La valeur doit être chap1::chap2::chap3")
        
        XCTAssert(dynamicScreen.tracker.buffer.volatileParameters["pid"]!.key == "pid", "Le paramètre doit être pid")
        XCTAssert(dynamicScreen.tracker.buffer.volatileParameters["pid"]!.values[0]() == "123", "La valeur doit être 123")
        
        XCTAssert(dynamicScreen.tracker.buffer.volatileParameters["pidt"]!.key == "pidt", "Le paramètre doit être pidt")
        XCTAssert(dynamicScreen.tracker.buffer.volatileParameters["pidt"]!.values[0]() == dateFormatter.string(from: curDate), "La valeur doit être curDate")
        
        XCTAssert(dynamicScreen.tracker.buffer.volatileParameters["p"]!.key == "p", "Le troisième paramètre doit être p")
        XCTAssert(dynamicScreen.tracker.buffer.volatileParameters["p"]!.values[0]() == "HomeDyn", "La valeur du troisième paramètre doit être HomeDyn")
    }
    
    func testSetDynamicScreenWithTooLongStringId() {
        dateFormatter.dateFormat = "YYYYMMddHHmm"
        
        var s = ""
        for i in 0 ..< 256 {
            s += String(i)
        }
        
        dynamicScreen.screenId = s
        dynamicScreen.update = curDate;
        dynamicScreen.name = "HomeDyn"
        dynamicScreen.chapter1 = "chap1"
        dynamicScreen.chapter2 = "chap2"
        dynamicScreen.chapter3 = "chap3"
        
        dynamicScreen.setParams()
        
        XCTAssertEqual(dynamicScreen.tracker.buffer.volatileParameters.count, 4, "Le nombre de paramètres volatiles doit être égal à 4")
        
        XCTAssert(dynamicScreen.tracker.buffer.volatileParameters["pchap"]!.key == "pchap", "Le paramètre doit être pchap")
        XCTAssert(dynamicScreen.tracker.buffer.volatileParameters["pchap"]!.values[0]() == "chap1::chap2::chap3", "La valeur doit être chap1::chap2::chap3")
        
        XCTAssert(dynamicScreen.tracker.buffer.volatileParameters["pid"]!.key == "pid", "Le paramètre doit être pid")
        XCTAssert(dynamicScreen.tracker.buffer.volatileParameters["pid"]!.values[0]() == "", "La valeur doit être vide")
        
        XCTAssert(dynamicScreen.tracker.buffer.volatileParameters["pidt"]!.key == "pidt", "Le paramètre doit être pidt")
        XCTAssert(dynamicScreen.tracker.buffer.volatileParameters["pidt"]!.values[0]() == dateFormatter.string(from: curDate), "La valeur doit être curDate")
        
        XCTAssert(dynamicScreen.tracker.buffer.volatileParameters["p"]!.key == "p", "Le troisième paramètre doit être p")
        XCTAssert(dynamicScreen.tracker.buffer.volatileParameters["p"]!.values[0]() == "HomeDyn", "La valeur du troisième paramètre doit être HomeDyn")
    }
    
    func testAddDynamicScreen() {
        dateFormatter.dateFormat = "YYYYMMddHHmm"
        
        dynamicScreen = dynamicScreens.add("123", update: curDate, name: "HomeDyn")
        
        XCTAssert(dynamicScreens.tracker.businessObjects.count == 1, "Le nombre d'objet en attente doit être égale à 1")
        
        XCTAssert(dynamicScreen.name == "HomeDyn", "Le nom de l'écran doit etre égal à HomeDyn")
        XCTAssert((dynamicScreens.tracker.businessObjects[dynamicScreen.id] as! DynamicScreen).name == "HomeDyn", "Le nom de l'écran doit etre égal à HomeDyn")
        
        XCTAssert(dynamicScreen.screenId == "123", "L'identifiant d'écran doit etre égal à 123")
        XCTAssert((dynamicScreens.tracker.businessObjects[dynamicScreen.id] as! DynamicScreen).screenId == "123", "L'identifiant d'écran doit etre égal à 123")
        
        XCTAssert(dynamicScreen.update == curDate, "La date de l'écran doit être égal à curDate")
        XCTAssert((dynamicScreens.tracker.businessObjects[dynamicScreen.id] as! DynamicScreen).update == curDate, "La date de l'écran doit être égal à curDate")
    }
    
    func testAddDynamicScreenWithChapter() {
        dateFormatter.dateFormat = "YYYYMMddHHmm"
        
        dynamicScreen = dynamicScreens.add("123", update: curDate, name: "HomeDyn", chapter1: "chap1")
        
        XCTAssert(dynamicScreens.tracker.businessObjects.count == 1, "Le nombre d'objet en attente doit être égale à 1")
        
        XCTAssert(dynamicScreen.name == "HomeDyn", "Le nom de l'écran doit etre égal à HomeDyn")
        XCTAssert((dynamicScreens.tracker.businessObjects[dynamicScreen.id] as! DynamicScreen).name == "HomeDyn", "Le nom de l'écran doit etre égal à HomeDyn")
        
        XCTAssert(dynamicScreen.screenId == "123", "L'identifiant d'écran doit etre égal à 123")
        XCTAssert((dynamicScreens.tracker.businessObjects[dynamicScreen.id] as! DynamicScreen).screenId == "123", "L'identifiant d'écran doit etre égal à 123")
        
        XCTAssert(dynamicScreen.update == curDate, "La date de l'écran doit être égal à curDate")
        XCTAssert((dynamicScreens.tracker.businessObjects[dynamicScreen.id] as! DynamicScreen).update == curDate, "La date de l'écran doit être égal à curDate")
        
        XCTAssert(dynamicScreen.chapter1 == "chap1", "Le chapitre 1 de l'écran doit être égal à chap1")
        XCTAssert((dynamicScreens.tracker.businessObjects[dynamicScreen.id] as! DynamicScreen).chapter1 == "chap1", "Le chapitre 1 de l'écran doit être égal à chap1")
    }
}
