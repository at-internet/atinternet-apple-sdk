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
//  CartCreation.swift
//  Tracker
//

/// Wrapper class for CartCreation event tracking (SalesInsight)
class CartCreation: Event {
    
    /// Cart property
    var cart : ECommerceCart = ECommerceCart()
    
    override var data: [String : Any] {
        get {
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
        super.init(name: "cart.creation")
    }
}

class ProductPurchased: Event {
    
    /// Product property
    lazy var product : ECommerceProduct = ECommerceProduct()
    
    /// Transaction property
    lazy var transaction : ECommerceTransaction = ECommerceTransaction()
    
    /// Cart property
    var cart = ECommerceCart()
    
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
        super.init(name: "product.purchased")
    }
}

class ProductAwaitingPayment: Event {
    
    /// Product property
    lazy var product : ECommerceProduct = ECommerceProduct()
    
    /// Cart property
    var cart = ECommerceCart()
    
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
        super.init(name: "product.awaiting_payment")
    }
}
