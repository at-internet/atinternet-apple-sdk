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
//  CartAwaitingPayment.swift
//  Tracker
//
import Foundation

/// Wrapper class for UpdateCart event tracking (SalesInsight)
public class CartAwaitingPayment: Event {
    
    /// Cart property
    @objc public lazy var cart : ECommerceCart = ECommerceCart()
    
    /// Products list
    @objc public lazy var products : [ECommerceProduct] = [ECommerceProduct]()
    
    /// Transaction property
    @objc public lazy var transaction : ECommerceTransaction = ECommerceTransaction()
    
    /// Shipping property
    @objc public lazy var shipping : ECommerceShipping = ECommerceShipping()
    
    /// Payment property
    @objc public lazy var payment : ECommercePayment = ECommercePayment()
    
    override var data: [String : Any] {
        get {
            var cartProps = cart.getProps()
            if !cartProps.isEmpty {
                cartProps["version"] = cart.version
                _data["cart"] = cartProps
            }
            let paymentProps = payment.getProps()
            if !paymentProps.isEmpty {
                _data["payment"] = paymentProps
            }
            let shippingProps = shipping.getProps()
            if !shippingProps.isEmpty {
                _data["shipping"] = shippingProps
            }
            let transactionProps = transaction.getProps()
            if !transactionProps.isEmpty {
                _data["transaction"] = transactionProps
            }
            return super.data
        }
        set {
            _data = newValue
        }
    }
    
    init() {
        super.init(name: "cart.awaiting_payment")
    }
    
    @objc public func setProducts(products: [ECommerceProduct]) {
        self.products = products
    }
    
    override func getAdditionalEvents() -> [Event] {
        var generatedEvents = super.getAdditionalEvents()
        
        for p in products {
            let pap = ProductAwaitingPayment()
            _ = pap.cart.setProps(obj:
                [
                    "id": String(describing: cart.get(key: "id") ?? ""),
                    "version": cart.version
                ])
            let productProps = p.getProps()
            if !productProps.isEmpty {
                _ = pap.product.setProps(obj: productProps)
            }
            generatedEvents.append(pap)
        }
       
        return generatedEvents
    }
}

/// Wrapper class to manage UpdateCart event instances
public class CartAwaitingPayments : EventsHelper {
    
    override init(events: Events) {
        super.init(events: events)
    }
    
    /// Add cart awaiting payment event tracking
    ///
    /// - Returns: CartAwaitingPayment instance
    @objc public func add() -> CartAwaitingPayment {
        let cap = CartAwaitingPayment()
        _ = events.add(event: cap)
        return cap
    }
    
    /// Add cart awaiting payment event tracking
    ///
    /// - Parameter screenLabel: a screen label
    /// - Returns: CartAwaitingPayment instance
    @available(*, deprecated, message: "Use 'add()' method instead")
    @objc public func add(screenLabel: String?) -> CartAwaitingPayment {
        return add()
    }
    
    /// Add cart awaiting payment event tracking
    ///
    /// - Parameter screen: a screen instance
    /// - Returns: CartAwaitingPayment instance
    @available(*, deprecated, message: "Use 'add()' method instead")
    @objc public func add(screen: Screen?) -> CartAwaitingPayment {
        return add()
    }
}
