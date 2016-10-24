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
//  IdentifiedVisitorTests.swift
//  Tracker
//

import UIKit
import XCTest

class IdentifiedVisitorTests: XCTestCase {
    
    let tracker = Tracker()

    func testSetAndUnsetNumericNotPersistent() {
        let expectation = self.expectationWithDescription("Config Set")
        
        tracker.setConfig(IdentifiedVisitorHelperKey.Configuration.rawValue, value: "false", completionHandler: {(isSet) in
            let refCount = self.tracker.buffer.persistentParameters.count
            self.tracker.identifiedVisitor.set(123)
            XCTAssertTrue(self.tracker.buffer.persistentParameters.count == refCount + 1, "Il doit y avoir un paramètre supplémentaire")
            var p = self.tracker.buffer.persistentParameters.last as Param!
            XCTAssertTrue(p.key == HitParam.VisitorIdentifierNumeric.rawValue, "Le dernier paramètre doit être l'id numérique")
            XCTAssertTrue(p.value() == "123", "Le dernier paramètre doit avoir la valeur 123")
            self.tracker.identifiedVisitor.unset()
            p = self.tracker.buffer.persistentParameters.last as Param!
            XCTAssertTrue(self.tracker.buffer.persistentParameters.count == refCount, "Il ne doit pas y avoir un paramètre supplémentaire")
            XCTAssertTrue(p.key != HitParam.VisitorIdentifierNumeric.rawValue, "Le dernier paramètre ne doit pas être l'id numérique")
            
            expectation.fulfill()
        })
        
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
    }
    
    func testSetAndUnsetNumericPersistent() {
        let expectation = self.expectationWithDescription("test")
        
        tracker.setConfig(IdentifiedVisitorHelperKey.Configuration.rawValue, value: "true", completionHandler:nil)
        
        let configurationOperation = NSBlockOperation(block: {
        let refCount = self.tracker.buffer.persistentParameters.count
        self.tracker.identifiedVisitor.set(123)
        XCTAssertTrue(self.tracker.buffer.persistentParameters.count == refCount, "Il ne doit pas y avoir de paramètre supplémentaire")
        let test = NSUserDefaults.standardUserDefaults().objectForKey(IdentifiedVisitorHelperKey.Numeric.rawValue) as! String
        XCTAssertTrue(test == "123", "La valeur doit être 123")
        self.tracker.identifiedVisitor.unset()
            XCTAssertNil(NSUserDefaults.standardUserDefaults().objectForKey(IdentifiedVisitorHelperKey.Numeric.rawValue), "Il ne doit pas y avoir de donnée")
            expectation.fulfill()
        })
        
        TrackerQueue.sharedInstance.queue.addOperation(configurationOperation)
        
        waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    func testSetAndUnsetNumericWithCategoryNotPersistent() {
        let expectation = self.expectationWithDescription("test")
        
        tracker.setConfig(IdentifiedVisitorHelperKey.Configuration.rawValue, value: "false", completionHandler:nil)
        
        let configurationOperation = NSBlockOperation(block: {
            let refCount = self.tracker.buffer.persistentParameters.count
            self.tracker.identifiedVisitor.set(123, visitorCategory: 456)
            XCTAssertTrue(self.tracker.buffer.persistentParameters.count == refCount + 2, "Il doit y avoir deux paramètres supplémentaires")
            var p = self.tracker.buffer.persistentParameters.last as Param!
            XCTAssertTrue(p.key == HitParam.VisitorCategory.rawValue, "Le dernier paramètre doit être la catégorie")
            XCTAssertTrue(p.value() == "456", "Le dernier paramètre doit avoir la valeur 456")
            self.tracker.identifiedVisitor.unset()
            p = self.tracker.buffer.persistentParameters.last as Param!
            XCTAssertTrue(self.tracker.buffer.persistentParameters.count == refCount, "Il ne doit pas y avoir un paramètre supplémentaire")
            XCTAssertTrue(p.key != HitParam.VisitorCategory.rawValue, "Le dernier paramètre ne doit pas être la catégorie")
            expectation.fulfill()
        })
        
        TrackerQueue.sharedInstance.queue.addOperation(configurationOperation)
        
        waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    func testSetAndUnsetNumericWithCategoryPersistent() {
        let expectation = self.expectationWithDescription("test")
        
        tracker.setConfig(IdentifiedVisitorHelperKey.Configuration.rawValue, value: "true", completionHandler:nil)
        let configurationOperation = NSBlockOperation(block: {
            let refCount = self.tracker.buffer.persistentParameters.count
            self.tracker.identifiedVisitor.set(123, visitorCategory: 456)
            XCTAssertTrue(self.tracker.buffer.persistentParameters.count == refCount, "Il ne doit pas y avoir de paramètre supplémentaire")
            var test = NSUserDefaults.standardUserDefaults().objectForKey(IdentifiedVisitorHelperKey.Numeric.rawValue) as! String
            XCTAssertTrue(test == "123", "La valeur doit être 123")
            test = NSUserDefaults.standardUserDefaults().objectForKey(IdentifiedVisitorHelperKey.Category.rawValue) as! String
            XCTAssertTrue(test == "456", "La valeur doit être 456")
            self.tracker.identifiedVisitor.unset()
            XCTAssertNil(NSUserDefaults.standardUserDefaults().objectForKey(IdentifiedVisitorHelperKey.Numeric.rawValue), "Il ne doit pas y avoir de donnée")
            XCTAssertNil(NSUserDefaults.standardUserDefaults().objectForKey(IdentifiedVisitorHelperKey.Category.rawValue), "Il ne doit pas y avoir de donnée")
            expectation.fulfill()
        })
        
        TrackerQueue.sharedInstance.queue.addOperation(configurationOperation)
        
        waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    func testSetAndUnsetTextNotPersistent() {
        let expectation = self.expectationWithDescription("test")
        
        tracker.setConfig(IdentifiedVisitorHelperKey.Configuration.rawValue, value: "false", completionHandler:nil)
        let configurationOperation = NSBlockOperation(block: {
            let refCount = self.tracker.buffer.persistentParameters.count
            self.tracker.identifiedVisitor.set("aze")
            XCTAssertTrue(self.tracker.buffer.persistentParameters.count == refCount + 1, "Il doit y avoir un paramètre supplémentaire")
            var p = self.tracker.buffer.persistentParameters.last as Param!
            XCTAssertTrue(p.key == HitParam.VisitorIdentifierText.rawValue, "Le dernier paramètre doit être l'id textuel")
            XCTAssertTrue(p.value() == "aze", "Le dernier paramètre doit avoir la valeur aze")
            self.tracker.identifiedVisitor.unset()
            p = self.tracker.buffer.persistentParameters.last as Param!
            XCTAssertTrue(self.tracker.buffer.persistentParameters.count == refCount, "Il ne doit pas y avoir un paramètre supplémentaire")
            XCTAssertTrue(p.key != HitParam.VisitorIdentifierNumeric.rawValue, "Le dernier paramètre ne doit pas être l'id textuel")
            expectation.fulfill()
        })
        
        TrackerQueue.sharedInstance.queue.addOperation(configurationOperation)
        waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    func testSetAndUnsetTextPersistent() {
        let expectation = self.expectationWithDescription("test")
        
        tracker.setConfig(IdentifiedVisitorHelperKey.Configuration.rawValue, value: "true", completionHandler:nil)
        let configurationOperation = NSBlockOperation(block: {
            let refCount = self.tracker.buffer.persistentParameters.count
            self.tracker.identifiedVisitor.set("123")
            XCTAssertTrue(self.tracker.buffer.persistentParameters.count == refCount, "Il ne doit pas y avoir de paramètre supplémentaire")
            let test = NSUserDefaults.standardUserDefaults().objectForKey(IdentifiedVisitorHelperKey.Text.rawValue) as! String
            XCTAssertTrue(test == "123", "La valeur doit être 123")
            self.tracker.identifiedVisitor.unset()
            XCTAssertNil(NSUserDefaults.standardUserDefaults().objectForKey(IdentifiedVisitorHelperKey.Text.rawValue), "Il ne doit pas y avoir de donnée")
            expectation.fulfill()
        })
        
        TrackerQueue.sharedInstance.queue.addOperation(configurationOperation)
        waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    func testSetAndUnsetTextWithCategoryNotPersistent() {
        tracker.setConfig(IdentifiedVisitorHelperKey.Configuration.rawValue, value: "false", completionHandler:nil)
            let configurationOperation = NSBlockOperation(block: {
            let refCount = self.tracker.buffer.persistentParameters.count
            self.tracker.identifiedVisitor.set("aze", visitorCategory: 456)
            XCTAssertTrue(self.tracker.buffer.persistentParameters.count == refCount + 2, "Il doit y avoir deux paramètres supplémentaires")
            var p = self.tracker.buffer.persistentParameters.last as Param!
            XCTAssertTrue(p.key == HitParam.VisitorCategory.rawValue, "Le dernier paramètre doit être la catégorie")
            XCTAssertTrue(p.value() == "456", "Le dernier paramètre doit avoir la valeur 456")
            self.tracker.identifiedVisitor.unset()
            p = self.tracker.buffer.persistentParameters.last as Param!
            XCTAssertTrue(self.tracker.buffer.persistentParameters.count == refCount, "Il ne doit pas y avoir un paramètre supplémentaire")
            XCTAssertTrue(p.key != HitParam.VisitorCategory.rawValue, "Le dernier paramètre ne doit pas être la catégorie")
        })
        
        TrackerQueue.sharedInstance.queue.addOperation(configurationOperation)
    }
    
    func testSetAndUnsetTextWithCategoryPersistent() {
        let expectation = self.expectationWithDescription("test")
        
        tracker.setConfig(IdentifiedVisitorHelperKey.Configuration.rawValue, value: "true", completionHandler:nil)
            let configurationOperation = NSBlockOperation(block: {
            let refCount = self.tracker.buffer.persistentParameters.count
            self.tracker.identifiedVisitor.set("123", visitorCategory: 456)
            XCTAssertTrue(self.tracker.buffer.persistentParameters.count == refCount, "Il ne doit pas y avoir de paramètre supplémentaire")
            var test = NSUserDefaults.standardUserDefaults().objectForKey(IdentifiedVisitorHelperKey.Text.rawValue) as! String
            XCTAssertTrue(test == "123", "La valeur doit être 123")
            test = NSUserDefaults.standardUserDefaults().objectForKey(IdentifiedVisitorHelperKey.Category.rawValue) as! String
            XCTAssertTrue(test == "456", "La valeur doit être 456")
            self.tracker.identifiedVisitor.unset()
            XCTAssertNil(NSUserDefaults.standardUserDefaults().objectForKey(IdentifiedVisitorHelperKey.Text.rawValue), "Il ne doit pas y avoir de donnée")
            XCTAssertNil(NSUserDefaults.standardUserDefaults().objectForKey(IdentifiedVisitorHelperKey.Category.rawValue), "Il ne doit pas y avoir de donnée")
                expectation.fulfill()
        })
        
        TrackerQueue.sharedInstance.queue.addOperation(configurationOperation)
        
        waitForExpectationsWithTimeout(10, handler: nil)
    }

}
