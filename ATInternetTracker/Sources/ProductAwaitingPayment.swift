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
//  ProductAwaitingPayment.swift
//  Tracker
//
import Foundation

/// Wrapper class for ProductAwaitingPayment event tracking (SalesInsight)
public class ProductAwaitingPayment : Event {
    
    /// Products property
    @objc public lazy var products : [ECommerceProduct] = [ECommerceProduct]()
    
    /// Cart property
    @objc public lazy var cart : ECommerceCart = ECommerceCart()
    
    override var data: [String : Any] {
        get {
            return _data
        }
    }
    
    init() {
        super.init(type: "product.awaiting_payment")
    }
    
    override func getAdditionalEvents() -> [Event] {
        var generatedEvents = super.getAdditionalEvents()
        
        for p in products {
            /// SALES INSIGHTS
            let pap = ProductAwaitingPayment()
            if !p.properties.isEmpty {
                pap._data["product"] = p.properties
            }
            if !cart.properties.isEmpty {
                pap._data["cart"] = cart.properties
            }
            generatedEvents.append(pap)
        }
        
        return generatedEvents
    }
}

/// Wrapper class to manage RemoveProduct event instances
public class ProductAwaitingPayments : EventsHelper {
    
    /// Add product awaiting payment event tracking
    ///
    /// - Returns: ProductAwaitingPayment instance
    @objc public func add() -> ProductAwaitingPayment {
        let pap = ProductAwaitingPayment()
        _ = events.add(event: pap)
        return pap
    }
}
