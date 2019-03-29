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
//  Order.swift
//  Tracker
//

import Foundation

/// Wrapper class to manage SalesTracker Order feature
public class Order: BusinessObject {
    fileprivate var _status: Int?
    fileprivate var _isNewCustomer: Bool?
    fileprivate var _paymentMethod: Int?
    fileprivate var _isConfirmationRequired: Bool?
    
    /// Order Id
    @objc public var orderId: String = ""
    /// Turnover
    @objc public var turnover: Double = 0.0
    /// Status
    @objc public var status: Int = -1 {
        didSet {
            _status = status
        }
    }
    /// Discount
    @objc public lazy var discount: OrderDiscount = OrderDiscount(order: self)
    /// Amount
    @objc public lazy var amount: OrderAmount = OrderAmount(order: self)
    /// Delivery info
    @objc public lazy var delivery: OrderDelivery = OrderDelivery(order: self)
    /// Custom variables
    @objc public lazy var customVariables: OrderCustomVars = OrderCustomVars()
    /// New Customer
    @objc public var isNewCustomer: Bool = false {
        didSet {
            _isNewCustomer = isNewCustomer
        }
    }
    /// Payment method
    @objc public var paymentMethod: Int = -1 {
        didSet {
            _paymentMethod = paymentMethod
        }
    }
    /// Requires confirmation
    @objc public var isConfirmationRequired: Bool = false {
        didSet {
            _isConfirmationRequired = isConfirmationRequired
        }
    }
    
    override init(tracker: Tracker) {
        super.init(tracker: tracker)
    }
    
    /// Create a new Order
    ///
    /// - Parameters:
    ///   - orderId: order identifier
    ///   - turnover: order turnover
    @objc public init(orderId: String, turnover: Double) {
        super.init()
        
        self.orderId = orderId
        self.turnover = turnover
    }
    
    /// Create a new Order
    ///
    /// - Parameters:
    ///   - orderId: order identifier
    ///   - turnover: order turnover
    ///   - status: order status 0=No information, 1=Pending, 2=cancelled, 3=approved, 4=return
    @objc public convenience init(orderId: String, turnover: Double, status: Int) {
        self.init(orderId: orderId, turnover: turnover)
        
        self._status = status
    }
    
    /// Set parameters in buffer
    override func setParams() {
        let encodingOption = ParamOption()
        encodingOption.encode = true
        
        _ = tracker.setParam("cmd", value: orderId)
        _ = tracker.setParam("roimt", value: turnover)
        
        if let optStatus = _status {
            _ = tracker.setParam("st", value: optStatus)
        }
        
        if let optIsNewCustomer = _isNewCustomer {
            _ = tracker.setParam("newcus", value: optIsNewCustomer ? 1 : 0)
        }        

        if discount.discountTaxFree != -1 {
            _ = tracker.setParam("dscht", value: discount.discountTaxFree)
        }
        
        if discount.discountTaxIncluded != -1 {
            _ = tracker.setParam("dsc", value: discount.discountTaxIncluded)
        }
        
        if let optPromotionalCode = discount.promotionalCode {
            _ = tracker.setParam("pcd", value: optPromotionalCode, options:encodingOption)
        }
        
        if amount.amountTaxFree != -1 {
            _ = tracker.setParam("mtht", value: amount.amountTaxFree)
        }
        
        if amount.amountTaxIncluded != -1 {
            _ = tracker.setParam("mtttc", value: amount.amountTaxIncluded)
        }
        
        if amount.taxAmount != -1 {
            _ = tracker.setParam("tax", value: amount.taxAmount)
        }
    
        if delivery.shippingFeesTaxFree != -1 {
            _ = tracker.setParam("fpht", value: delivery.shippingFeesTaxFree)
        }
        
        if delivery.shippingFeesTaxIncluded != -1 {
            _ = tracker.setParam("fp", value: delivery.shippingFeesTaxIncluded)
        }
        
        if let optDeliveryMethod = delivery.deliveryMethod {
            _ = tracker.setParam("dl", value: optDeliveryMethod, options:encodingOption)
        }
        
        for(_, customVar) in customVariables.list.enumerated() {
            _ = tracker.setParam("o" + String(customVar.varId), value: customVar.value)
        }
        
        if let optPaymentMethod = _paymentMethod {
            _ = tracker.setParam("mp", value: optPaymentMethod)
        }
        
        if let _ = _isConfirmationRequired {
            _ = tracker.setParam("tp", value: "pre1")
        }
    }
}

/// Wrapper class to manage Orders instances
public class Orders: NSObject {
    /// Tracker instance
    var tracker: Tracker
    
    /**
    Orders initializer
    - parameter tracker: the tracker instance
    - returns: Orders instance
    */
    init(tracker: Tracker) {
        self.tracker = tracker;
    }
    
    /// Add an order
    ///
    /// - Parameters:
    ///   - orderId: order identifier
    ///   - turnover: order turnover
    /// - Returns: Order instance
    @discardableResult
    @objc public func add(_ orderId: String, turnover: Double) -> Order {
        let order = Order(tracker: tracker)
        order.orderId = orderId
        order.turnover = turnover
        tracker.businessObjects[order.id] = order
        
        return order
    }
    
    ///  Add an order
    ///
    /// - Parameters:
    ///   - orderId: order identifier
    ///   - turnover: order turnover
    ///   - status: order status. 0=No information, 1=Pending, 2=cancelled, 3=approved, 4=return
    /// - Returns: Order instance
    @discardableResult @objc public func add(_ orderId: String, turnover: Double, status: Int) -> Order {
        let order = add(orderId, turnover: turnover)
        order.status = status
        
        return order
    }
}

/// Wrapper class to manage specific order discount feature
public class OrderDiscount: NSObject {
    
    /// Order instance
    weak var order: Order!
    
    /// Discount with tax
    @objc public var discountTaxIncluded: Double = -1
    /// Discount without tax
    @objc public var discountTaxFree: Double = -1
    /// Promotional code
    @objc public var promotionalCode: String?
    
    /**
    OrderDiscount initializer
    - parameter order: the order instance
    - returns: OrderDiscount instance
    */
    init(order: Order) {
        self.order = order
    }
    
    /// Attach discount to order
    ///
    /// - Parameters:
    ///   - discountTaxFree: discount value tax free
    ///   - discountTaxIncluded: discount value tax included
    ///   - promotionalCode: promotional code
    /// - Returns: the Order instance
    @objc public func set(_ discountTaxFree: Double, discountTaxIncluded: Double, promotionalCode: String) -> Order {
        self.discountTaxIncluded = discountTaxIncluded
        self.discountTaxFree = discountTaxFree
        self.promotionalCode = promotionalCode
        
        return order
    }
}

/// Wrapper class to manage specific order amount feature
public class OrderAmount: NSObject {
    
    /// Order instance
    weak var order: Order!
    
    /// Amount without tax
    @objc public var amountTaxFree: Double = -1
    
    /// Amount with tax
    @objc public var amountTaxIncluded: Double = -1
    
    /// Tax amount
    @objc public var taxAmount: Double = -1
    
    /**
    OrderAmount initializer
    - parameter order: the order instance
    - returns: OrderAmount instance
    */
    init(order: Order) {
        self.order = order
    }
    
    /// Attach amount object to order
    ///
    /// - Parameters:
    ///   - amountTaxFree: amount value tax free
    ///   - amountTaxIncluded:  amount value tax included
    ///   - taxAmount: tax amount
    /// - Returns: the Order instance
    @objc public func set(_ amountTaxFree: Double, amountTaxIncluded: Double, taxAmount: Double) -> Order {
        self.amountTaxFree = amountTaxFree
        self.amountTaxIncluded = amountTaxIncluded
        self.taxAmount = taxAmount
        
        return self.order
    }
}

/// Wrapper class to manage specific order delivery feature
public class OrderDelivery: NSObject {
    
    /// Order instance
    weak var order: Order!
    
    /// Shipping fees with tax
    @objc public var shippingFeesTaxIncluded: Double = -1
    /// Shipping fees without tax
    @objc public var shippingFeesTaxFree: Double = -1
    /// Delivery method
    @objc public var deliveryMethod: String?
    
    /// OrderDelivery initializer
    ///
    /// - Parameter order: the order instance
    init(order: Order) {
        self.order = order
    }
    
    /// Attach delivery to order
    ///
    /// - Parameters:
    ///   - shippingFeesTaxFree: shipping fees tax free
    ///   - shippingFeesTaxIncluded: shipping fees tax included
    ///   - deliveryMethod: delivery method
    /// - Returns: the Order instance
    @objc public func set(_ shippingFeesTaxFree: Double, shippingFeesTaxIncluded: Double, deliveryMethod: String) -> Order {
        self.shippingFeesTaxFree = shippingFeesTaxFree
        self.shippingFeesTaxIncluded = shippingFeesTaxIncluded
        self.deliveryMethod = deliveryMethod
        
        return order
    }
}

/// Wrapper class for tracking order custom variables
public class OrderCustomVar: NSObject {
    
    /// Custom var identifier
    @objc public var varId: Int = 0
    /// Custom var value
    @objc public var value: String = ""
    
    /// initializer
    ///
    /// - Parameters:
    ///   - varId: custom var identifier
    ///   - value: custom var value
    init(varId: Int, value: String) {
        self.varId = varId
        self.value = value
    }
}

/// Wrapper class to manage OrderCustomVar instances
public class OrderCustomVars: NSObject {
    
    /// Custom var list
    lazy var list: [OrderCustomVar] = []

    /// Add a custom var
    ///
    /// - Parameters:
    ///   - varId: custom var identifier
    ///   - value: custom var value
    /// - Returns: the OrderCustomVar instance
    @objc public func add(_ varId: Int, value: String) ->  OrderCustomVar {
        let customVar = OrderCustomVar(varId: varId, value: value)
        
        list.append(customVar)
        
        return customVar
    }
}
