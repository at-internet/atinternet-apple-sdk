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
//  AddProduct.swift
//  Tracker
//
import Foundation

/// Wrapper class for AddProduct event tracking (SalesInsight)
public class AddProduct: Event {
    
    /// Product property
    @objc public lazy var product : ECommerceProduct = ECommerceProduct()
    
    /// Cart property
    @objc public lazy var cart : ECommerceCart = ECommerceCart()
    
    override var data: [String : Any] {
        get {
            let productProps = product.getProps()
            if !productProps.isEmpty {
                _data["product"] = productProps
            }
            let cartProps = cart.getProps()
            if !cartProps.isEmpty {
                _data["cart"] = cartProps
            }
            return super.data
        }
        set {
            _data = newValue
        }
    }
    
    init() {
        super.init(name: "product.add_to_cart")
    }
    
    override func getAdditionalEvents() -> [Event] {
        var generatedEvents = super.getAdditionalEvents()
        
        if String(describing: product.get(key: "cartcreation") ?? false).toBool() {
            let cc = CartCreation()
            let quantity = Int(String(describing: product.get(key: "quantity") ?? 0)) ?? 0
            
            _ = cc.cart.set(key: "id", value: String(describing: cart.get(key: "id") ?? ""))
                .set(key: "currency", value: String(describing: product.get(key: "currency") ?? ""))
                .set(key: "turnovertaxincluded", value: (Double(String(describing: product.get(key: "pricetaxincluded") ?? 0)) ?? 0) * Double(quantity))
                .set(key: "turnovertaxfree", value: (Double(String(describing: product.get(key: "pricetaxfree") ?? 0)) ?? 0) * Double(quantity))
                .set(key: "quantity", value: quantity)
                .set(key: "nbdistinctproduct", value: 1)
            
            generatedEvents.append(cc)
        }
        
        return generatedEvents
    }
}

/// Wrapper class to manage AddProduct event instances
public class AddProducts : EventsHelper {
    
    /// Add add product event tracking
    ///
    /// - Returns: AddProduct instance
    @objc public func add() -> AddProduct {
        let ap = AddProduct()
        _ = events.add(event: ap)
        return ap
    }
}
