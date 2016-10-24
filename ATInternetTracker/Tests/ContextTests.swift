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
//  ContextTests.swift
//  Tracker
//

import UIKit
import XCTest

class ContextTests: XCTestCase {
    
    let tracker = Tracker()

    func testBackgroundMode() {
        if (tracker.context.backgroundMode != nil) {
            XCTAssertTrue(false, "Par défaut le mode background doit être à nil")
        }
        tracker.context.backgroundMode = .Fetch
        XCTAssertTrue(tracker.context.backgroundMode == .Fetch, "Le mode background doit être fetch")
        var p = tracker.buffer.persistentParameters.last as Param!
        XCTAssertTrue(p.key == HitParam.BackgroundMode.rawValue, "Le dernier paramètre persistent doit être le mode background")
        XCTAssertTrue(p.value() == "fetch", "Le dernier paramètre persistent doit avoir la valeur fetch")
        tracker.context.backgroundMode = .Task
        p = tracker.buffer.persistentParameters.last as Param!
        XCTAssertTrue(p.key == HitParam.BackgroundMode.rawValue, "Le dernier paramètre persistent doit être le mode background")
        XCTAssertTrue(p.value() == "task", "Le dernier paramètre persistent doit avoir la valeur task")
        tracker.context.backgroundMode = .Normal
        p = tracker.buffer.persistentParameters.last as Param!
        XCTAssertTrue(p.key != HitParam.BackgroundMode.rawValue, "Le dernier paramètre persistent ne doit pas être le mode background")
    }
    
    func testLevel2() {
        if (tracker.context.level2 != nil) {
            XCTAssertTrue(false, "Par défaut le level2 doit être à nil")
        }
        tracker.context.level2 = 123
        var p = tracker.buffer.persistentParameters.last as Param!
        XCTAssertTrue(p.key == HitParam.Level2.rawValue, "Le dernier paramètre persistent doit être le level 2")
        XCTAssertTrue(p.value() == "123", "Le dernier paramètre persistent doit avoir la valeur 123")
        tracker.context.level2 = nil
        p = tracker.buffer.persistentParameters.last as Param!
        XCTAssertTrue(p.key != HitParam.Level2.rawValue, "Le dernier paramètre persistent ne doit pas être le level 2")
    }

}
