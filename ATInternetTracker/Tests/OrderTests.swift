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
//  OrderTests.swift
//  Tracker
//

import UIKit
import XCTest
@testable import ATInternetTracker

class OrderTests: XCTestCase {
    
    var order: Order!
    var orders: Orders!

    override func setUp() {
        super.setUp()
        
        order = Order(tracker: Tracker())
        orders = Orders(tracker: order.tracker)
    }
    
    func testSetOrder() {
        order.orderId = "cmd1"
        _ = order.amount.set(50, amountTaxIncluded: 60, taxAmount: 10)
        _ = order.discount.set(5, discountTaxIncluded: 10, promotionalCode: "1234")
        _ = order.delivery.set(2, shippingFeesTaxIncluded: 6, deliveryMethod: "1[UPS]")
        order.isConfirmationRequired = true
        order.isNewCustomer = true
        order.paymentMethod = 1
        order.status = 1
        order.turnover = 10.123
        _ = order.customVariables.add(1, value: "test")
        _ = order.customVariables.add(2, value: "test2")
        
        order.setParams()
        
        XCTAssert(order.tracker.buffer.volatileParameters.count == 17, "Le nombre de paramètres volatiles doit être égal à 17")
        
        XCTAssert(order.tracker.buffer.volatileParameters["cmd"]!.key == "cmd", "Le premier paramètre doit être cmd")
        XCTAssert(order.tracker.buffer.volatileParameters["cmd"]!.values[0]() == "cmd1", "La valeur du premier paramètre doit être cmd1")
        
        XCTAssert(order.tracker.buffer.volatileParameters["roimt"]!.key == "roimt", "Le second paramètre doit être roimt")
        XCTAssert(order.tracker.buffer.volatileParameters["roimt"]!.values[0]() == "10.123", "La valeur du second paramètre doit être 10")
        
        XCTAssert(order.tracker.buffer.volatileParameters["st"]!.key == "st", "Le 3ème paramètre doit être st")
        XCTAssert(order.tracker.buffer.volatileParameters["st"]!.values[0]() == "1", "La valeur du 3ème paramètre doit être 1")
        
        XCTAssert(order.tracker.buffer.volatileParameters["newcus"]!.key == "newcus", "Le 4ème paramètre doit être newcus")
        XCTAssert(order.tracker.buffer.volatileParameters["newcus"]!.values[0]() == "1", "La valeur du 4ème paramètre doit être 1")
        
        XCTAssert(order.tracker.buffer.volatileParameters["dscht"]!.key == "dscht", "Le 5ème paramètre doit être dscht")
        XCTAssert(order.tracker.buffer.volatileParameters["dscht"]!.values[0]() == "5", "La valeur du 5ème paramètre doit être 5")
        
        XCTAssert(order.tracker.buffer.volatileParameters["dsc"]!.key == "dsc", "Le 6ème paramètre doit être dsc")
        XCTAssert(order.tracker.buffer.volatileParameters["dsc"]!.values[0]() == "10", "La valeur du 6ème paramètre doit être 10")
        
        XCTAssert(order.tracker.buffer.volatileParameters["pcd"]!.key == "pcd", "Le 7ème paramètre doit être pcd")
        XCTAssert(order.tracker.buffer.volatileParameters["pcd"]!.values[0]() == "1234", "La valeur du 7ème paramètre doit être 1234")
        
        XCTAssert(order.tracker.buffer.volatileParameters["mtht"]!.key == "mtht", "Le 8ème paramètre doit être mtht")
        XCTAssert(order.tracker.buffer.volatileParameters["mtht"]!.values[0]() == "50", "La valeur du 8ème paramètre doit être 50")
        
        XCTAssert(order.tracker.buffer.volatileParameters["mtttc"]!.key == "mtttc", "Le 9ème paramètre doit être mtttc")
        XCTAssert(order.tracker.buffer.volatileParameters["mtttc"]!.values[0]() == "60", "La valeur du 9ème paramètre doit être 60")
        
        XCTAssert(order.tracker.buffer.volatileParameters["tax"]!.key == "tax", "Le 10ème paramètre doit être tax")
        XCTAssert(order.tracker.buffer.volatileParameters["tax"]!.values[0]() == "10", "La valeur du 10ème paramètre doit être 10")
        
        XCTAssert(order.tracker.buffer.volatileParameters["fpht"]!.key == "fpht", "Le 11ème paramètre doit être fpht")
        XCTAssert(order.tracker.buffer.volatileParameters["fpht"]!.values[0]() == "2", "La valeur du 11ème paramètre doit être 2")
        
        XCTAssert(order.tracker.buffer.volatileParameters["fp"]!.key == "fp", "Le 12ème paramètre doit être fp")
        XCTAssert(order.tracker.buffer.volatileParameters["fp"]!.values[0]() == "6", "La valeur du 12ème paramètre doit être 6")
        
        XCTAssert(order.tracker.buffer.volatileParameters["dl"]!.key == "dl", "Le 13ème paramètre doit être dl")
        XCTAssert(order.tracker.buffer.volatileParameters["dl"]!.values[0]() == "1[UPS]", "La valeur du 13ème paramètre doit être 1")
        
        XCTAssert(order.tracker.buffer.volatileParameters["o1"]!.key == "o1", "Le 14ème paramètre doit être o1")
        XCTAssert(order.tracker.buffer.volatileParameters["o1"]!.values[0]() == "test", "La valeur du 14ème paramètre doit être test")
        
        XCTAssert(order.tracker.buffer.volatileParameters["o2"]!.key == "o2", "Le 15ème paramètre doit être o2")
        XCTAssert(order.tracker.buffer.volatileParameters["o2"]!.values[0]() == "test2", "La valeur du 15ème paramètre doit être test2")
        
        XCTAssert(order.tracker.buffer.volatileParameters["mp"]!.key == "mp", "Le 16ème paramètre doit être mp")
        XCTAssert(order.tracker.buffer.volatileParameters["mp"]!.values[0]() == "1", "La valeur du 16ème paramètre doit être 1")
        
        XCTAssert(order.tracker.buffer.volatileParameters["tp"]!.key == "tp", "Le 17ème paramètre doit être tp")
        XCTAssert(order.tracker.buffer.volatileParameters["tp"]!.values[0]() == "pre1", "La valeur du 17ème paramètre doit être pre1")


    }
    
}
