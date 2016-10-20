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
//  TVTrackingTests.swift
//  Tracker
//

import UIKit
import XCTest

class TVTrackingTests: XCTestCase {
    
    func testSetTVTNotEnabled() {
        let expectation = self.expectation(description: "test")
        
        let tracker = Tracker(configuration: ["log":"logp", "logSSL":"logs", "domain":"xiti.com", "pixelPath":"/hit.xiti", "site":"549808", "secure":"false", "identifier":"uuid", "plugins": "", "storage":"required","enableBackgroundTask":"true", "hashUserId": "false","persistIdentifiedVisitor":"true","tvtUrl":"http://tochange.com/resources/spot4","tvtVisitDuration":"1"])
        
        _ = tracker.tvTracking.set()

        let configurationOperation = BlockOperation(block: {
            XCTAssertTrue(tracker.buffer.volatileParameters.count == 0, "Le paramètre tvtracking ne doit pas être ajouté")
            expectation.fulfill()
        })
        
        TrackerQueue.sharedInstance.queue.addOperation(configurationOperation)
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testSetTVTEnabled() {
        let expectation = self.expectation(description: "test")
        
        let tracker = Tracker(configuration: ["log":"logp", "logSSL":"logs", "domain":"xiti.com", "pixelPath":"/hit.xiti", "site":"549808", "secure":"false", "identifier":"uuid", "plugins": "tvtracking", "storage":"required","enableBackgroundTask":"true", "hashUserId": "false","persistIdentifiedVisitor":"true","tvtUrl":"http://tochange.com/resources/spot4","tvtVisitDuration":"1"])

        _ = tracker.tvTracking.set()
        
        let configurationOperation = BlockOperation(block: {
            let p0 = tracker.buffer.persistentParameters.last as Param!
            XCTAssertTrue(p0?.key == "tvt", "Le paramètre doit être la clé du plugin NuggAd")
            XCTAssertTrue(p0?.value() == "true", "La valeur doit être true")
            expectation.fulfill()
        })
        
        TrackerQueue.sharedInstance.queue.addOperation(configurationOperation)
        
        waitForExpectations(timeout: 10, handler: nil)
    }

}
