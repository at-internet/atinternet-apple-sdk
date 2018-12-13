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
//  PaymentCheckout.swift
//  Tracker
//
import Foundation

/// Wrapper class for PaymentCheckout event tracking (SalesInsight)
public class PaymentCheckout: EcommerceEvent {
    
    /// Cart property
    @objc public var cart = ECommerceCart()
    
    /// Shipping property
    @objc public var shipping = ECommerceShipping()
    
    override var data: [String : Any] {
        get {
            _data["cart"] = cart.properties
            _data["shipping"] = shipping.properties
            return super.data
        }
    }
    
    init(screen: Screen?) {
        super.init(action: "cart.payment", screen: screen)
    }
}

/// Wrapper class to manage PaymentCheckout event instances
public class PaymentCheckouts : EventsHelper {
    
    /// Add payment checkout event tracking
    ///
    /// - Parameter screen: a screen instance
    /// - Returns: PaymentCheckout instance
    @objc public func add(screen: Screen?) -> PaymentCheckout {
        let pc = PaymentCheckout(screen: screen)
        _ = events.add(event: pc)
        return pc
    }
}
