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
//  CampaignTests.swift
//  Tracker
//

import UIKit
import XCTest

class CampaignTests: XCTestCase {
    lazy var campaign: Campaign = Campaign(tracker: Tracker())
    lazy var campaigns: Campaigns = Campaigns(tracker: Tracker())
    let userDefaults = NSUserDefaults.standardUserDefaults()
    
    override func setUp() {
        campaign = Campaign(tracker: Tracker())
        campaigns = Campaigns(tracker: campaign.tracker)
        
        userDefaults.removeObjectForKey("ATCampaign")
        userDefaults.removeObjectForKey("ATCampaignDate")
        userDefaults.synchronize()
    }
    
    func testSetCampaign() {
        campaign.campaignId = "AD-1"
        campaign.setEvent()
        
        XCTAssert(campaign.tracker.buffer.volatileParameters.count == 1, "Le nombre de paramètres volatiles doit être égal à 1")
        
        XCTAssert(campaign.tracker.buffer.volatileParameters[0].key == "xto", "Le premier paramètre doit être xto")
        XCTAssert(campaign.tracker.buffer.volatileParameters[0].value() == "AD-1", "La valeur du premier paramètre doit être AD-1")
    }
    
    func testSetCampaignWithRemanent() {
        let expectation = expectationWithDescription("test")
        
        campaign.tracker.setConfig("campaignLastPersistence", value: "false") { (isSet) -> Void in
            self.campaign.campaignId = "AD-1"
            self.campaign.setEvent()
            
            self.campaign.campaignId = "AD-2"
            self.campaign.setEvent()
            
            XCTAssert(self.campaign.tracker.buffer.volatileParameters.count == 2, "Le nombre de paramètres volatiles doit être égal à 2")
            
            XCTAssert(self.campaign.tracker.buffer.volatileParameters[0].key == "xto", "Le premier paramètre doit être xto")
            XCTAssert(self.campaign.tracker.buffer.volatileParameters[0].value() == "AD-2", "La valeur du premier paramètre doit être AD-2")
            
            XCTAssert(self.campaign.tracker.buffer.volatileParameters[1].key == "xtor", "Le premier paramètre doit être xtor")
            XCTAssert(self.campaign.tracker.buffer.volatileParameters[1].value() == "AD-1", "La valeur du premier paramètre doit être AD-1")
            
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(10, handler: nil)
        
    }
    
    func testSetCampaignWithLastPersistence() {
        let expectation = expectationWithDescription("test")
        
        campaign.tracker.setConfig("campaignLastPersistence", value: "true") { (isSet) -> Void in
            self.campaign.campaignId = "AD-1"
            self.campaign.setEvent()
            
            self.campaign.campaignId = "AD-2"
            self.campaign.setEvent()
            
            self.campaign.campaignId = "AD-3"
            self.campaign.setEvent()
            
            XCTAssert(self.campaign.tracker.buffer.volatileParameters.count == 2, "Le nombre de paramètres volatiles doit être égal à 2")
            
            XCTAssert(self.campaign.tracker.buffer.volatileParameters[0].key == "xto", "Le premier paramètre doit être xto")
            XCTAssert(self.campaign.tracker.buffer.volatileParameters[0].value() == "AD-3", "La valeur du premier paramètre doit être AD-3")
            
            XCTAssert(self.campaign.tracker.buffer.volatileParameters[1].key == "xtor", "Le premier paramètre doit être xtor")
            XCTAssert(self.campaign.tracker.buffer.volatileParameters[1].value() == "AD-2", "La valeur du premier paramètre doit être AD-2")
            
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    func testSetCampaignWithFirstPersistence() {
        let expectation = expectationWithDescription("test")
        
        campaign.tracker.setConfig("campaignLastPersistence", value: "false") { (isSet) -> Void in
            self.campaign.campaignId = "AD-1"
            self.campaign.setEvent()
            
            self.campaign.campaignId = "AD-2"
            self.campaign.setEvent()
            
            self.campaign.campaignId = "AD-3"
            self.campaign.setEvent()
            
            XCTAssert(self.campaign.tracker.buffer.volatileParameters.count == 2, "Le nombre de paramètres volatiles doit être égal à 2")
            
            XCTAssert(self.campaign.tracker.buffer.volatileParameters[0].key == "xto", "Le premier paramètre doit être xto")
            XCTAssert(self.campaign.tracker.buffer.volatileParameters[0].value() == "AD-3", "La valeur du premier paramètre doit être AD-3")
            
            XCTAssert(self.campaign.tracker.buffer.volatileParameters[1].key == "xtor", "Le premier paramètre doit être xtor")
            XCTAssert(self.campaign.tracker.buffer.volatileParameters[1].value() == "AD-1", "La valeur du premier paramètre doit être AD-1")
            
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(10, handler: nil)
    }
    
}
