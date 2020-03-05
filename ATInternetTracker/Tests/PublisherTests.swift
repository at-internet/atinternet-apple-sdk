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
@testable import ATInternetTracker

class PublisherTests: XCTestCase {
    
    lazy var publisher: Publisher = Publisher(tracker: Tracker())
    lazy var publisher2: Publisher = Publisher(tracker: Tracker())
    lazy var publishers: Publishers = Publishers(tracker: Tracker())
    func lookupParam(key: String, params: [ (key: String, value: (String, String)) ]) -> (key: String, value: (String, String)) {
        return params.filter({ (tuple) -> Bool in
            return tuple.key == key
        })[0]
    }
    func testInitPublisher() {
        XCTAssertTrue(publisher.campaignId == "", "Le nom de la pub doit être vide")
        XCTAssertTrue(publisher.action == OnAppAd.OnAppAdAction.view, "L'action par défaut doit être view")
    }
    
    func testSetPublisherView() {
        publisher.campaignId = "1"
        publisher.setParams()
        
        XCTAssertEqual(publisher.tracker.buffer.volatileParameters.count, 2, "Le nombre de paramètres volatiles doit être égal à 2")
        XCTAssert(publisher.tracker.buffer.volatileParameters["type"]?.key == "type", "Le premier paramètre doit être type")
        XCTAssert(publisher.tracker.buffer.volatileParameters["type"]?.values[0]() == "AT", "La valeur du premier paramètre doit être AT")
        
        XCTAssert(publisher.tracker.buffer.volatileParameters["ati"]?.key == "ati", "Le second paramètre doit être action")
        XCTAssert(publisher.tracker.buffer.volatileParameters["ati"]?.values[0]() == "PUB-1-------", "La valeur du second paramètre doit être PUB-1-------")
    }
    
    func testSetFullPublisherView() {
        publisher.campaignId = "2"
        publisher.creation = "creation"
        publisher.advertiserId = "advId"
        publisher.detailedPlacement = "enBasAGauche"
        publisher.generalPlacement = "quelquePart"
        publisher.url = "atinternet"
        publisher.variant = "variante"
        publisher.format = "format"
        publisher.setParams()
        
        XCTAssertEqual(publisher.tracker.buffer.volatileParameters.count, 2, "Le nombre de paramètres volatiles doit être égal à 2")
        XCTAssert(publisher.tracker.buffer.volatileParameters["type"]?.key == "type", "Le premier paramètre doit être type")
        XCTAssert(publisher.tracker.buffer.volatileParameters["type"]?.values[0]() == "AT", "La valeur du premier paramètre doit être AT")
        
        XCTAssert(publisher.tracker.buffer.volatileParameters["ati"]?.key == "ati", "Le second paramètre doit être action")
        XCTAssert(publisher.tracker.buffer.volatileParameters["ati"]?.values[0]() == "PUB-2-creation-variante-format-quelquePart-enBasAGauche-advId-atinternet", "La valeur du second paramètre doit être PUB-2-creation-variante-format-quelquePart-enBasAGauche-advId-atinternet")
    }
    
    func testMultiplePublisherViews() {
        publisher.campaignId = "1"
        publisher.setParams()
        
        publisher2.tracker = publisher.tracker
        publisher2.campaignId = "2"
        publisher2.creation = "creation"
        publisher2.advertiserId = "advId"
        publisher2.detailedPlacement = "enBasAGauche"
        publisher2.generalPlacement = "quelquePart"
        publisher2.url = "atinternet"
        publisher2.variant = "variante"
        publisher2.format = "format"
        publisher2.setParams()
        
        XCTAssertEqual(publisher.tracker.buffer.volatileParameters.count, 2, "Le nombre de paramètres volatiles doit être égal à 3")
        XCTAssert(publisher.tracker.buffer.volatileParameters["type"]?.key == "type", "Le premier paramètre doit être type")
        XCTAssert(publisher.tracker.buffer.volatileParameters["type"]?.values[0]() == "AT", "La valeur du premier paramètre doit être AT")
        
        XCTAssert(publisher.tracker.buffer.volatileParameters["ati"]?.key == "ati", "Le second paramètre doit être action")
        XCTAssert(publisher.tracker.buffer.volatileParameters["ati"]?.values[0]() == "PUB-1-------", "La valeur du second paramètre doit être PUB-1-------")
        
        XCTAssert(publisher.tracker.buffer.volatileParameters["ati"]?.key == "ati", "Le 3ème paramètre doit être action")
        XCTAssert(publisher.tracker.buffer.volatileParameters["ati"]?.values[1]() == "PUB-2-creation-variante-format-quelquePart-enBasAGauche-advId-atinternet", "La valeur du 3ème paramètre doit être PUB-2-creation-variante-format-quelquePart-enBasAGauche-advId-atinternet")
        
        let builder = Builder(tracker: publisher.tracker)
        let params: [String : (String, String)] = builder.prepareQuery()
        
        XCTAssertTrue(params["ati"]?.0 == "&ati=" + "PUB%2D1%2D%2D%2D%2D%2D%2D%2D%2CPUB%2D2%2Dcreation%2Dvariante%2Dformat%2DquelquePart%2DenBasAGauche%2DadvId%2Datinternet")
    }
    
    func testSetScreenWithPublisherView() {
        let screen = publisher.tracker.screens.add("Home")
        screen.setParams()
        
        let p = screen.publishers.add("1")
        p.setParams()
        
        XCTAssertEqual(publisher.tracker.buffer.volatileParameters.count, 2, "Le nombre de paramètres volatiles doit être égal à 2")
        
        XCTAssert(publisher.tracker.buffer.volatileParameters["p"]?.key == "p", "Le troisième paramètre doit être p")
        XCTAssert(publisher.tracker.buffer.volatileParameters["p"]?.values[0]() == "Home", "La valeur du troisième paramètre doit être Home")

        
        XCTAssert(publisher.tracker.buffer.volatileParameters["ati"]?.key == "ati", "Le 5ème paramètre doit être action")
        XCTAssert(publisher.tracker.buffer.volatileParameters["ati"]?.values[0]() == "PUB-1-------", "La valeur du 5ème paramètre doit être PUB-1-------")
    }
    
    func testSetPublisherTouch() {
        publisher.campaignId = "1"
        publisher.action = OnAppAd.OnAppAdAction.touch
        publisher.setParams()
        
        XCTAssertEqual(publisher.tracker.buffer.volatileParameters.count, 2, "Le nombre de paramètres volatiles doit être égal à 2")
        XCTAssert(publisher.tracker.buffer.volatileParameters["type"]?.key == "type", "Le premier paramètre doit être type")
        XCTAssert(publisher.tracker.buffer.volatileParameters["type"]?.values[0]() == "AT", "La valeur du premier paramètre doit être AT")
        
        XCTAssert(publisher.tracker.buffer.volatileParameters["atc"]?.key == "atc", "Le second paramètre doit être action")
        XCTAssert(publisher.tracker.buffer.volatileParameters["atc"]?.values[0]() == "PUB-1-------", "La valeur du second paramètre doit être PUB-1-------")
    }
    
    func testSetFullPublisherTouch() {
        publisher.campaignId = "2"
        publisher.action = OnAppAd.OnAppAdAction.touch
        publisher.creation = "creation"
        publisher.advertiserId = "advId"
        publisher.detailedPlacement = "enBasAGauche"
        publisher.generalPlacement = "quelquePart"
        publisher.url = "atinternet"
        publisher.variant = "variante"
        publisher.format = "format"
        publisher.setParams()
        
        XCTAssertEqual(publisher.tracker.buffer.volatileParameters.count, 2, "Le nombre de paramètres volatiles doit être égal à 2")
        XCTAssert(publisher.tracker.buffer.volatileParameters["type"]?.key == "type", "Le premier paramètre doit être type")
        XCTAssert(publisher.tracker.buffer.volatileParameters["type"]?.values[0]() == "AT", "La valeur du premier paramètre doit être AT")
        
        XCTAssert(publisher.tracker.buffer.volatileParameters["atc"]?.key == "atc", "Le second paramètre doit être action")
        XCTAssert(publisher.tracker.buffer.volatileParameters["atc"]?.values[0]() == "PUB-2-creation-variante-format-quelquePart-enBasAGauche-advId-atinternet", "La valeur du second paramètre doit être PUB-2-creation-variante-format-quelquePart-enBasAGauche-advId-atinternet")
    }
}

