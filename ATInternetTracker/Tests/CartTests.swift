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
//  CartTests.swift
//  Tracker
//

import UIKit
import XCTest

class CartTests: XCTestCase {
    
    lazy var cart: Cart = Cart(tracker: Tracker())
    
    override func setUp() {
        super.setUp()
        
        cart.unset()
    }
    
    func testSetCart() {
        _ = cart.set("1")
        cart.setEvent()

        XCTAssert(cart.tracker.buffer.volatileParameters.count == 1, "Le nombre de paramètres volatiles doit être égal à 1")
        
        XCTAssert(cart.tracker.buffer.volatileParameters[0].key == "idcart", "Le premier paramètre doit être idcart")
        XCTAssert(cart.tracker.buffer.volatileParameters[0].value() == "1", "La valeur du premier paramètre doit être 1")
    }
    
    func testUnsetCart() {
        _ = cart.set("1")
        _ = cart.products.add("1")
        _ = cart.products.add("2")
        
        XCTAssert(cart.productList.count == 2, "Le nombre de produits doit être égal à 2")
        XCTAssert(cart.cartId == "1", "l'id du panier doit être égal à 1")
        
        cart.unset()
        
        XCTAssert(cart.productList.count == 0, "Le nombre de produits doit être égal à 0")
        XCTAssert(cart.cartId == "", "l'id du panier doit être égal à 0")
    }
    
    func testAddProduct2Cart() {
        _ = cart.set("1")
        let product1 = cart.products.add("Nike Air Jordan")
        product1.category1 = "Chaussures"
        product1.quantity = 1
        product1.promotionalCode = "1234"
        product1.unitPriceTaxFree = 100
        product1.unitPriceTaxIncluded = 120
        product1.discountTaxFree = 5
        product1.discountTaxIncluded = 10
        
        cart.setEvent()
        
        XCTAssert(cart.tracker.buffer.volatileParameters.count == 8, "Le nombre de paramètres volatiles doit être égal à 8")
        
        XCTAssert(cart.tracker.buffer.volatileParameters[0].key == "idcart", "Le premier paramètre doit être idcart")
        XCTAssert(cart.tracker.buffer.volatileParameters[0].value() == "1", "La valeur du premier paramètre doit être 1")
        
        XCTAssert(cart.tracker.buffer.volatileParameters[1].key == "pdt1", "Le second paramètre doit être pdt1")
        XCTAssert(cart.tracker.buffer.volatileParameters[1].value() == "Chaussures::Nike Air Jordan", "La valeur du second paramètre doit être Chaussures::Nike Air Jordan")
        
        XCTAssert(cart.tracker.buffer.volatileParameters[2].key == "qte1", "Le 3ème paramètre doit être qte1")
        XCTAssert(cart.tracker.buffer.volatileParameters[2].value() == "1", "La valeur du 3ème paramètre doit être 1")
        
        XCTAssert(cart.tracker.buffer.volatileParameters[3].key == "mtht1", "Le 4ème paramètre doit être mtht1")
        XCTAssert(cart.tracker.buffer.volatileParameters[3].value() == "100", "La valeur du 4ème paramètre doit être 100")
        
        XCTAssert(cart.tracker.buffer.volatileParameters[4].key == "mt1", "Le 5ème paramètre doit être mt1")
        XCTAssert(cart.tracker.buffer.volatileParameters[4].value() == "120", "La valeur du 5ème paramètre doit être 120")
        
        XCTAssert(cart.tracker.buffer.volatileParameters[5].key == "dscht1", "Le 6ème paramètre doit être dscht1")
        XCTAssert(cart.tracker.buffer.volatileParameters[5].value() == "5", "La valeur du 6ème paramètre doit être 5")
        
        XCTAssert(cart.tracker.buffer.volatileParameters[6].key == "dsc1", "Le 7ème paramètre doit être dsc1")
        XCTAssert(cart.tracker.buffer.volatileParameters[6].value() == "10", "La valeur du 7ème paramètre doit être 10")
        
        XCTAssert(cart.tracker.buffer.volatileParameters[7].key == "pcode1", "Le 8ème paramètre doit être pcode1")
        XCTAssert(cart.tracker.buffer.volatileParameters[7].value() == "1234", "La valeur du 8ème paramètre doit être 1234")
    }
}
