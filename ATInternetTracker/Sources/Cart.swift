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
//  Cart.swift
//  Tracker
//

import Foundation

/// Wrapper class to manage your cart
public class Cart: BusinessObject {
    
    /// Cart identifier
    @objc public var cartId: String = ""
    
    /// Cart products
    @objc public lazy var products: Products = Products(cart: self)
    
    /// Product list
    lazy var productList: [Product] = [Product]()
    
    /// Set a cart
    ///
    /// - Parameter cartId: the cart identifier
    /// - Returns: the cart
    @objc public func set(_ cartId: String) -> Cart {
        if(cartId != self.cartId) {
            products.removeAll()
        }
        
        self.cartId = cartId
        self.tracker.businessObjects[self.id] = self

        return self
    }
    
    /**
    Unset the cart
    */
    @objc public func unset() {
        self.cartId = ""
        self.products.removeAll()
        
        self.tracker.businessObjects.removeValue(forKey: self.id)
    }
    
    /**
     Send the cart
     */
    @objc public func send() {
        self.tracker.dispatcher.dispatch([self])
        self.unset()
    }
    
    /// Set parameters in buffer
    override func setParams() {
        _ = tracker.setParam("idcart", value: cartId)
        
        let encodingOption = ParamOption()
        encodingOption.encode = true
        for(i, product) in productList.enumerated() {
            _ = tracker.setParam("pdt" + String(i+1), value: product.buildProductName(), options:encodingOption)
            
            if product.quantity != -1 {
                _ = tracker.setParam("qte" + String(i+1), value: product.quantity)
            }
            
            if product.unitPriceTaxFree != -1 {
                _ = tracker.setParam("mtht" + String(i+1), value: product.unitPriceTaxFree)
            }
            
            if product.unitPriceTaxIncluded != -1 {
                _ = tracker.setParam("mt" + String(i+1), value: product.unitPriceTaxIncluded)
            }
            
            if product.discountTaxFree != -1 {
                _ = tracker.setParam("dscht" + String(i+1), value: product.discountTaxFree)
            }
            
            if product.discountTaxIncluded != -1 {
                _ = tracker.setParam("dsc" + String(i+1), value: product.discountTaxIncluded)
            }
            
            if let optPromotionalCode = product.promotionalCode {
                _ = tracker.setParam("pcode" + String(i+1), value: optPromotionalCode, options:encodingOption)
            }
        }
    }
}
