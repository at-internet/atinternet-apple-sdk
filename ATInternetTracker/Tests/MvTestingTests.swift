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
//  MvTestingTests.swift
//  Tracker
//

import UIKit
import XCTest
@testable import ATInternetTracker

class MvTestingTests: XCTestCase {
    
    func testInitMvTesting() {
        let mvt: MvTesting = MvTesting(tracker: Tracker())
        XCTAssertTrue(mvt.test == "", "Test doit être vide")
        XCTAssertTrue(mvt.waveId == -1, "WaveId doit etre égal à -1")
        XCTAssertTrue(mvt.creation == "", "Creation doit être vide")
    }
    
    func testSetMvTesting() {
        let mvt1 = Tracker().mvTestings.add("test", waveId: 1, creation: "crea")
        _ = mvt1.variables.add("var", version: "vers")
        mvt1.setParams()
        
        XCTAssertEqual(mvt1.tracker.buffer.volatileParameters.count, 3, "Le nombre de paramètres volatiles doit être égal à 3")
        
        XCTAssert(mvt1.tracker.buffer.volatileParameters["type"]!.key == "type", "Le premier paramètre doit être type")
        XCTAssert(mvt1.tracker.buffer.volatileParameters["type"]!.values[0]() == "mvt", "La valeur du premier paramètre doit être mvt")
        
        XCTAssert(mvt1.tracker.buffer.volatileParameters["abmvc"]!.key == "abmvc", "Le second paramètre doit être abmvc")
        XCTAssert(mvt1.tracker.buffer.volatileParameters["abmvc"]!.values[0]() == "test-1-crea", "La valeur du second paramètre doit être test-1-crea")
        
        XCTAssert(mvt1.tracker.buffer.volatileParameters["abmv1"]!.key == "abmv1", "Le 4ème paramètre doit être abmv1")
        XCTAssert(mvt1.tracker.buffer.volatileParameters["abmv1"]!.values[0]() == "var-vers", "La valeur du 4ème paramètre doit être var-vers")
    }
}
