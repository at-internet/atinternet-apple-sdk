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
//  TransactionConfirmation.swift
//  Tracker
//
import Foundation

/// Wrapper class for TransactionConfirmation event tracking (SalesInsight)
public class TransactionConfirmation: Event {
    
    private var tracker : Tracker
    
    private var screen : Screen?
    
    /// Products list
    @objc public lazy var products : [ECommerceProduct] = [ECommerceProduct]()
    
    /// Cart property
    @objc public lazy var cart : ECommerceCart = ECommerceCart()
    
    /// Transaction property
    @objc public lazy var transaction : ECommerceTransaction = ECommerceTransaction()
    
    /// Shipping property
    @objc public lazy var shipping : ECommerceShipping = ECommerceShipping()
    
    /// Payment property
    @objc public lazy var payment : ECommercePayment = ECommercePayment()
    
    /// Customer property
    @objc public lazy var customer : ECommerceCustomer = ECommerceCustomer()
    
    /// Promotional codes
    @objc public var promotionalCodes = [String]()
    
    override var data: [String : Any] {
        get {
            _data["cart"] = cart.properties
            _data["payment"] = payment.properties
            _data["customer"] = customer.properties
            _data["shipping"] = shipping.properties
            _data["transaction"] = transaction.properties
            _data["a:s:promotionalCode"] = promotionalCodes
            return super.data
        }
    }
    
    init(tracker: Tracker, screen: Screen?) {
        self.tracker = tracker
        self.screen = screen
        super.init(type: "transaction.confirmation")
    }
    
    @objc public func setProducts(products: [ECommerceProduct]) {
        self.products = products
    }
    
    @objc public func setPromotionalCodes(codes: [String]) {
        self.promotionalCodes = codes
    }
    
    override func getAdditionalEvents() -> [Event] {
        /// SALES INSIGHTS
        var generatedEvents = super.getAdditionalEvents()
        let cc = CartConfirmation()
        _ = cc.transaction.setAll(obj: transaction.properties)
        _ = cc.cart.setAll(obj: cart.properties)
        generatedEvents.append(cc)
        
        for p in products {
            let pp = ProductPurchased()
            _ = pp.cart.set(key: "id", value: String(describing: cart.get(key: "s:id") ?? ""))
            _ = pp.transaction.set(key: "id", value: String(describing: transaction.get(key: "s:id") ?? ""))
            _ = pp.product.setAll(obj: p.properties)
            generatedEvents.append(pp)
        }
        
        /// SALES TRACKER
        if let autoSalesTrackerStr = tracker.configuration.parameters[TrackerConfigurationKeys.AutoSalesTracker], autoSalesTrackerStr.toBool() && screen != nil {
            
            let turnoverTaxIncluded = Double(String(describing: cart.get(key: "f:turnovertaxincluded") ?? 0)) ?? 0
            let turnoverTaxFree = Double(String(describing: cart.get(key: "f:turnovertaxfree") ?? 0)) ?? 0
            
            let o = tracker.orders.add(String(describing: transaction.get(key: "s:id") ?? ""), turnover: turnoverTaxIncluded)
            o.status = 3
            o.paymentMethod = 0
            o.isConfirmationRequired = false
            o.isNewCustomer = String(describing: customer.get(key: "b:new") ?? false).toBool()
            _ = o.delivery.set(Double(String(describing: shipping.get(key: "f:costtaxfree") ?? 0)) ?? 0, shippingFeesTaxIncluded: Double(String(describing: shipping.get(key: "f:costtaxincluded") ?? 0)) ?? 0, deliveryMethod: String(describing: shipping.get(key: "s:delivery") ?? ""))
            _ = o.amount.set(turnoverTaxFree, amountTaxIncluded: turnoverTaxIncluded, taxAmount: turnoverTaxIncluded - turnoverTaxFree)
            
            _ = o.discount.promotionalCode = promotionalCodes.joined(separator: "|")
            
            let stCart = tracker.cart.set(String(describing: cart.get(key: "s:id") ?? ""))
            
            for p in products {
                var stProductId : String
                if let name = (p as RequiredPropertiesDataObject).get(key: "s:$") {
                    stProductId = String(format: "%@[%@]", String(describing: p.get(key: "s:id") ?? ""), String(describing: name))
                } else {
                    stProductId = String(describing: p.get(key: "s:id") ?? "")
                }
                
                let stProduct = stCart.products.add(stProductId)
                stProduct.quantity = Int(String(describing: p.get(key: "n:quantity") ?? 0)) ?? 0
                stProduct.unitPriceTaxIncluded = Double(String(describing: p.get(key: "f:pricetaxincluded") ?? 0)) ?? 0
                stProduct.unitPriceTaxFree = Double(String(describing: p.get(key: "f:pricetaxfree") ?? 0)) ?? 0
                
                if let category1 = p.get(key: "s:category1") {
                    stProduct.category1 = String(format: "[%@]", String(describing: category1))
                }
                
                if let category2 = p.get(key: "s:category2") {
                    stProduct.category2 = String(format: "[%@]", String(describing: category2))
                }
                
                if let category3 = p.get(key: "s:category3") {
                    stProduct.category3 = String(format: "[%@]", String(describing: category3))
                }
                
                if let category4 = p.get(key: "s:category4") {
                    stProduct.category4 = String(format: "[%@]", String(describing: category4))
                }
                
                if let category5 = p.get(key: "s:category5") {
                    stProduct.category5 = String(format: "[%@]", String(describing: category5))
                }
                
                if let category6 = p.get(key: "s:category6") {
                    stProduct.category6 = String(format: "[%@]", String(describing: category6))
                }
            }
            
            var info = mach_timebase_info()
            mach_timebase_info(&info)
            screen!.timeStamp = mach_absolute_time() * UInt64(info.numer) / UInt64(info.denom)
            screen!.cart = stCart
            screen!.isBasketScreen = false
            
            screen!.sendView()
            screen!.cart = nil
            stCart.unset()
        }
        return generatedEvents
    }
}

/// Wrapper class to manage TransactionConfirmation event instances
public class TransactionConfirmations : EventsHelper {
    
    private let tracker : Tracker
    
    init(events: Events, tracker: Tracker) {
        self.tracker = tracker
        super.init(events: events)
    }
    
    /// Add transaction confirmation event tracking
    ///
    /// - Parameter screen: a screen instance
    /// - Returns: TransactionConfirmation instance
    @objc public func add(screen: Screen?) -> TransactionConfirmation {
        let tc = TransactionConfirmation(tracker: tracker, screen: screen)
        _ = events.add(event: tc)
        return tc
    }
}
