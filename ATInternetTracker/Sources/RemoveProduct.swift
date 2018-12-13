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
//  RemoveProduct.swift
//  Tracker
//
import Foundation

/// Wrapper class for RemoveProduct event tracking (SalesInsight)
public class RemoveProduct: EcommerceEvent {
    
    /// Product property
    @objc public var product = ECommerceProduct()
    
    /// Cart property
    @objc public var cart = ECommerceCart()
    
    override var data: [String : Any] {
        get {
            _data["product"] = product.properties
            _data["cart"] = cart.properties
            return super.data
        }
    }
    
    init(screen: Screen?) {
        super.init(action: "product.remove_from_cart", screen: screen)
    }
}

/// Wrapper class to manage RemoveProduct event instances
public class RemoveProducts : EventsHelper {
    
    /// Add remove product event tracking
    ///
    /// - Parameter screen: a screen instance
    /// - Returns: RemoveProduct instance
    @objc public func add(screen: Screen?) -> RemoveProduct {
        let rp = RemoveProduct(screen: screen)
        _ = events.add(event: rp)
        return rp
    }
}
