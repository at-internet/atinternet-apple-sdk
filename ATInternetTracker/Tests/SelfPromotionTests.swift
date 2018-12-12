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
//  PublisherTests.swift
//  Tracker
//

import XCTest

class SelfPromotionTests: XCTestCase {
    override func setUp() {
        super.setUp()
        
        TechnicalContext.level2 = -1
        TechnicalContext.screenName = ""
    }
    
    lazy var selfPromo: SelfPromotion = SelfPromotion(tracker: Tracker())
    lazy var selfPromo2: SelfPromotion = SelfPromotion(tracker: Tracker())
    lazy var selfPromos: SelfPromotions = SelfPromotions(tracker: Tracker())
    func lookupParam(key: String, params: [ (key: String, value: (String, String)) ]) -> (key: String, value: (String, String)) {
        return params.filter({ (tuple) -> Bool in
            return tuple.key == key
        })[0]
    }
    func testInitSelfPromo() {
        XCTAssertTrue(selfPromo.adId == 0, "L'id de la pub doit être égal à 0")
        XCTAssertTrue(selfPromo.action == OnAppAd.OnAppAdAction.view, "L'action par défaut doit être view")
    }
    
    func testSetSelfPromoView() {
        selfPromo.adId = 1
        selfPromo.setParams()
        
        XCTAssertEqual(selfPromo.tracker.buffer.volatileParameters.count, 2, "Le nombre de paramètres volatiles doit être égal à 2")
        XCTAssert(selfPromo.tracker.buffer.volatileParameters["type"]?.key == "type", "Le premier paramètre doit être type")
        XCTAssert(selfPromo.tracker.buffer.volatileParameters["type"]?.values[0]() == "AT", "La valeur du premier paramètre doit être AT")
        
        XCTAssert(selfPromo.tracker.buffer.volatileParameters["ati"]?.key == "ati", "Le second paramètre doit être action")
        XCTAssert(selfPromo.tracker.buffer.volatileParameters["ati"]?.values[0]() == "INT-1-||", "La valeur du second paramètre doit être INT-1-||")
    }
    
    func testSetFullSelfPromoView() {
        selfPromo.adId = 2
        selfPromo.productId = "productId"
        selfPromo.format = "format"
        selfPromo.setParams()
        
        XCTAssertEqual(selfPromo.tracker.buffer.volatileParameters.count, 2, "Le nombre de paramètres volatiles doit être égal à 2")
        XCTAssert(selfPromo.tracker.buffer.volatileParameters["type"]?.key == "type", "Le premier paramètre doit être type")
        XCTAssert(selfPromo.tracker.buffer.volatileParameters["type"]?.values[0]() == "AT", "La valeur du premier paramètre doit être AT")
        
        XCTAssert(selfPromo.tracker.buffer.volatileParameters["ati"]?.key == "ati", "Le second paramètre doit être action")
        XCTAssert(selfPromo.tracker.buffer.volatileParameters["ati"]?.values[0]() == "INT-2-format||productId", "La valeur du second paramètre doit être INT-2-format||productId")
    }
    
    func testMultiplePublisherViews() {
        selfPromo.adId = 1
        selfPromo.setParams()
        
        selfPromo2.tracker = selfPromo.tracker
        selfPromo2.adId = 2
        selfPromo2.productId = "productId"
        selfPromo2.format = "format"
        selfPromo2.setParams()
        
        XCTAssertEqual(selfPromo.tracker.buffer.volatileParameters.count, 2, "Le nombre de paramètres volatiles doit être égal à 2")
        XCTAssert(selfPromo.tracker.buffer.volatileParameters["type"]?.key == "type", "Le premier paramètre doit être type")
        XCTAssert(selfPromo.tracker.buffer.volatileParameters["type"]?.values[0]() == "AT", "La valeur du premier paramètre doit être AT")
        
        XCTAssert(selfPromo.tracker.buffer.volatileParameters["ati"]?.key == "ati", "Le second paramètre doit être action")
        XCTAssert(selfPromo.tracker.buffer.volatileParameters["ati"]?.values[0]() == "INT-1-||", "La valeur du second paramètre doit être INT-1-||")
        
        XCTAssert(selfPromo.tracker.buffer.volatileParameters["ati"]?.key == "ati", "Le 3ème paramètre doit être action")
        XCTAssert(selfPromo.tracker.buffer.volatileParameters["ati"]?.values[1]() == "INT-2-format||productId", "La valeur du 3ème paramètre doit être INT-2-format||productId")
        
        let builder = Builder(tracker: selfPromo.tracker)
        let params: [String : (String, String)] = builder.prepareQuery()
        
        XCTAssertTrue(params["ati"]?.0 == "&ati=" + "INT%2D1%2D%7C%7C%2CINT%2D2%2Dformat%7C%7CproductId")
    }
    
    func testSetScreenWithPublisherView() {
        let screen = selfPromo.tracker.screens.add("Home")
        screen.setParams()
        
        let s = screen.selfPromotions.add(1)
        s.setParams()
        
        XCTAssertEqual(selfPromo.tracker.buffer.volatileParameters.count, 2, "Le nombre de paramètres volatiles doit être égal à 2")
        
        XCTAssert(selfPromo.tracker.buffer.volatileParameters["p"]?.key == "p", "Le troisième paramètre doit être p")
        XCTAssert(selfPromo.tracker.buffer.volatileParameters["p"]?.values[0]() == "Home", "La valeur du troisième paramètre doit être Home")
        
        
        XCTAssert(selfPromo.tracker.buffer.volatileParameters["ati"]?.key == "ati", "Le 5ème paramètre doit être action")
        XCTAssert(selfPromo.tracker.buffer.volatileParameters["ati"]?.values[0]() == "INT-1-||", "La valeur du 5ème paramètre doit être INT-1-||")
    }
    
    func testSetPublisherTouch() {
        selfPromo.adId = 1
        selfPromo.action = OnAppAd.OnAppAdAction.touch
        selfPromo.setParams()
        print(selfPromo.tracker.buffer.volatileParameters)
        XCTAssertEqual(selfPromo.tracker.buffer.volatileParameters.count, 2, "Le nombre de paramètres volatiles doit être égal à 2")
        XCTAssert(selfPromo.tracker.buffer.volatileParameters["type"]?.key == "type", "Le premier paramètre doit être type")
        XCTAssert(selfPromo.tracker.buffer.volatileParameters["type"]?.values[0]() == "AT", "La valeur du premier paramètre doit être AT")
        
        XCTAssert(selfPromo.tracker.buffer.volatileParameters["atc"]?.key == "atc", "Le second paramètre doit être action")
        XCTAssert(selfPromo.tracker.buffer.volatileParameters["atc"]?.values[0]() == "INT-1-||", "La valeur du second paramètre doit être INT-1-||")
    }
    
    func testSetFullPublisherTouch() {
        selfPromo.action = OnAppAd.OnAppAdAction.touch
        selfPromo.adId = 2
        selfPromo.productId = "productId"
        selfPromo.format = "format"
        selfPromo.setParams()
        XCTAssertEqual(selfPromo.tracker.buffer.volatileParameters.count, 2, "Le nombre de paramètres volatiles doit être égal à 2")
        XCTAssert(selfPromo.tracker.buffer.volatileParameters["type"]?.key == "type", "Le premier paramètre doit être type")
        XCTAssert(selfPromo.tracker.buffer.volatileParameters["type"]?.values[0]() == "AT", "La valeur du premier paramètre doit être AT")
        
        XCTAssert(selfPromo.tracker.buffer.volatileParameters["atc"]?.key == "atc", "Le second paramètre doit être action")
        XCTAssert(selfPromo.tracker.buffer.volatileParameters["atc"]?.values[0]() == "INT-2-format||productId", "La valeur du second paramètre doit être INT-2-format||productId")
    }
}

