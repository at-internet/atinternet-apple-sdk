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
//  NuggAdTests.swift
//  Tracker
//

import UIKit
import XCTest

class NuggAdTests: XCTestCase {
    
    func testSetNuggAdNotEnabled() {
        let expectation = self.expectation(description: "test")
        
        let tracker = Tracker(configuration: ["log":"logp", "logSSL":"logs", "domain":"xiti.com", "pixelPath":"/hit.xiti", "site":"549808", "secure":"false", "identifier":"uuid", "plugins": "", "storage":"required","enableBackgroundTask":"true", "hashUserId": "false","persistIdentifiedVisitor":"true","tvtUrl":"http://tochange.com/resources/spot4","tvtVisitDuration":"1"])

        let nuggAd = tracker.nuggAds.add(["k0": "v0", "k1": "v1"])
        nuggAd.setEvent()
        
        let configurationOperation = BlockOperation(block: {
            XCTAssertTrue(tracker.buffer.volatileParameters.count == 0, "Le paramètre NuggAd ne doit pas être ajouté")
            expectation.fulfill()
        })
        
        TrackerQueue.sharedInstance.queue.addOperation(configurationOperation)
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testSetNuggAdEnabled() {
        let expectation = self.expectation(description: "test")
        
        let tracker = Tracker(configuration: ["log":"logp", "logSSL":"logs", "domain":"xiti.com", "pixelPath":"/hit.xiti", "site":"549808", "secure":"false", "identifier":"uuid", "plugins": "nuggad", "storage":"required","enableBackgroundTask":"true", "hashUserId": "false","persistIdentifiedVisitor":"true","tvtUrl":"http://tochange.com/resources/resources/spot4","tvtVisitDuration":"1", "sessionBackgroundDuration":"60"])
        let nuggAd = tracker.nuggAds.add(["k0": "v0"])
        nuggAd.setEvent()
        
        let configurationOperation = BlockOperation(block: {
            let p0 = tracker.buffer.volatileParameters[0] as Param!
            XCTAssertTrue(p0?.key == "stc", "Le paramètre doit être la clé du plugin NuggAd")
            XCTAssertTrue(p0?.value() == "{\"nuggad\":{\"k0\":\"v0\"}}", "La valeur doit être la data nuggad serialisée")
            expectation.fulfill()
        })
        
        TrackerQueue.sharedInstance.queue.addOperation(configurationOperation)
        
        waitForExpectations(timeout: 10, handler: nil)
    }
}
