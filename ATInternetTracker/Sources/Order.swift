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

public class Order: BusinessObject {
    private var _status: Int?
    private var _isNewCustomer: Bool?
    private var _paymentMethod: Int?
    private var _isConfirmationRequired: Bool?
    
    /// Order Id
    public var orderId: String = ""
    /// Turnover
    public var turnover: Double = 0.0
    /// Status
    public var status: Int = -1 {
        didSet {
            _status = status
        }
    }
    /// Discount
    public lazy var discount: OrderDiscount = OrderDiscount(order: self)
    /// Amount
    public lazy var amount: OrderAmount = OrderAmount(order: self)
    /// Delivery info
    public lazy var delivery: OrderDelivery = OrderDelivery(order: self)
    /// Custom variables
    public lazy var customVariables: OrderCustomVars = OrderCustomVars(order: self)
    /// New Customer
    public var isNewCustomer: Bool = false {
        didSet {
            _isNewCustomer = isNewCustomer
        }
    }
    /// Payment method
    public var paymentMethod: Int = -1 {
        didSet {
            _paymentMethod = paymentMethod
        }
    }
    /// Requires confirmation
    public var isConfirmationRequired: Bool = false {
        didSet {
            _isConfirmationRequired = isConfirmationRequired
        }
    }
    
    override init(tracker: Tracker) {
        super.init(tracker: tracker)
    }
    
    public init(orderId: String, turnover: Double) {
        super.init()
        
        self.orderId = orderId
        self.turnover = turnover
    }
    
    public convenience init(orderId: String, turnover: Double, status: Int) {
        self.init(orderId: orderId, turnover: turnover)
        
        self.status = status
    }
    
    /// Set parameters in buffer
    override func setEvent() {
        let encodingOption = ParamOption()
        encodingOption.encode = true
        
        tracker.setParam("cmd", value: orderId)
        tracker.setParam("roimt", value: turnover)
        
        if let optStatus = _status {
            tracker.setParam("st", value: optStatus)
        }
        
        if let optIsNewCustomer = _isNewCustomer {
            tracker.setParam("newcus", value: optIsNewCustomer ? 1 : 0)
        }        

        if let optDiscountTaxFree = discount.discountTaxFree {
            tracker.setParam("dscht", value: optDiscountTaxFree)
        }
        
        if let optDiscountTaxIncluded = discount.discountTaxIncluded {
            tracker.setParam("dsc", value: optDiscountTaxIncluded)
        }
        
        if let optPromotionalCode = discount.promotionalCode {
            tracker.setParam("pcd", value: optPromotionalCode, options:encodingOption)
        }
        
        if let optAmountTaxFree = amount.amountTaxFree {
            tracker.setParam("mtht", value: optAmountTaxFree)
        }
        
        if let optAmountTaxIncluded = amount.amountTaxIncluded {
            tracker.setParam("mtttc", value: optAmountTaxIncluded)
        }
        
        if let optTaxAmount = amount.taxAmount {
            tracker.setParam("tax", value: optTaxAmount)
        }
    
        if let optShippingFeesTaxFree = delivery.shippingFeesTaxFree {
            tracker.setParam("fpht", value: optShippingFeesTaxFree)
        }
        
        if let optShippingFeesTaxIncluded = delivery.shippingFeesTaxIncluded {
            tracker.setParam("fp", value: optShippingFeesTaxIncluded)
        }
        
        if let optDeliveryMethod = delivery.deliveryMethod {
            tracker.setParam("dl", value: optDeliveryMethod, options:encodingOption)
        }
        
        for(_, customVar) in customVariables.list.enumerate() {
            tracker.setParam("O" + String(customVar.varId), value: customVar.value)
        }
        
        if let optPaymentMethod = _paymentMethod {
            tracker.setParam("mp", value: optPaymentMethod)
        }
        
        if let _ = _isConfirmationRequired {
            tracker.setParam("tp", value: "pre1")
        }
    }
}

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
    
    /**
    Set an order
    - parameter orderId: order identifier
    - parameter turnover: order turnover
    - returns: Order instance
    */
    public func add(orderId: String, turnover: Double) -> Order {
        let order = Order(tracker: tracker)
        order.orderId = orderId
        order.turnover = turnover
        tracker.businessObjects[order.id] = order
        
        return order
    }
    
    /**
    Set an order
    - parameter orderId: order identifier
    - parameter turnover: order turnover
    - parameter status: order status
    - returns: Order instance
    */
    public func add(orderId: String, turnover: Double, status: Int) -> Order {
        let order = add(orderId, turnover: turnover)
        order.status = status
        
        return order
    }
}

public class OrderDiscount: NSObject {
    
    /// Order instance
    var order: Order
    
    /// Discount with tax
    public var discountTaxIncluded: Double?
    /// Discount without tax
    public var discountTaxFree: Double?
    /// Promotional code
    public var promotionalCode: String?
    
    /**
    OrderDiscount initializer
    - parameter order: the order instance
    - returns: OrderDiscount instance
    */
    init(order: Order) {
        self.order = order
    }
    
    /**
    Set a discount
    - parameter discountTaxFree: discount value tax free
    - parameter discountTaxIncluded: discount value tax included
    - parameter promotionalCode: promotional code
    - returns: the Order instance
    */
    public func set(discountTaxFree: Double, discountTaxIncluded: Double, promotionalCode: String) -> Order {
        self.discountTaxIncluded = discountTaxIncluded
        self.discountTaxFree = discountTaxFree
        self.promotionalCode = promotionalCode
        
        return order
    }
}

public class OrderAmount: NSObject {
    
    /// Order instance
    var order: Order
    
    /// Amount without tax
    public var amountTaxFree: Double?
    
    /// Amount with tax
    public var amountTaxIncluded: Double?
    
    /// Tax amount
    public var taxAmount: Double?
    
    /**
    OrderAmount initializer
    - parameter order: the order instance
    - returns: OrderAmount instance
    */
    init(order: Order) {
        self.order = order
    }
    
    /**
    Set an amount
    - parameter amountTaxFree: amount value tax free
    - parameter amountTaxIncluded: amount value tax included
    - parameter taxAmount: tax amount
    - returns: the Order instance
    */
    public func set(amountTaxFree: Double, amountTaxIncluded: Double, taxAmount: Double) -> Order {
        self.amountTaxFree = amountTaxFree
        self.amountTaxIncluded = amountTaxIncluded
        self.taxAmount = taxAmount
        
        return self.order
    }
}

public class OrderDelivery: NSObject {
    
    /// Order instance
    var order: Order
    
    /// Shipping fees with tax
    public var shippingFeesTaxIncluded: Double?
    /// Shipping fees without tax
    public var shippingFeesTaxFree: Double?
    /// Delivery method
    public var deliveryMethod: String?
    
    /**
    OrderDelivery initializer
    - parameter order: the order instance
    - returns: OrderDelivery instance
    */
    init(order: Order) {
        self.order = order
    }
    
    /**
    Set a delivery
    - parameter shippingFeesTaxFree: shipping fees tax free
    - parameter shippingFeesTaxIncluded: shipping fees tax included
    - parameter deliveryMethod: delivery method
    - returns: the Order instance
    */
    public func set(shippingFeesTaxFree: Double, shippingFeesTaxIncluded: Double, deliveryMethod: String) -> Order {
        self.shippingFeesTaxFree = shippingFeesTaxFree
        self.shippingFeesTaxIncluded = shippingFeesTaxIncluded
        self.deliveryMethod = deliveryMethod
        
        return order
    }
}

public class OrderCustomVar: NSObject {
    
    /// Custom var identifier
    public var varId: Int = 0
    /// Custom var value
    public var value: String = ""
    
    /**
    OrderCustomVar initializer
    - parameter varId: custom var identifier
    - parameter value: custom var value
    - returns: OrderCustomVar instance
    */
    init(varId: Int, value: String) {
        self.varId = varId
        self.value = value
    }
}

public class OrderCustomVars: NSObject {
    
    /// Order instance
    var order: Order
    
    /// Custom var list
    lazy var list: [OrderCustomVar] = []
    
    /**
    OrderCustomVars initializer
    - parameter order: the order instance
    - returns: OrderCustomVars instance
    */
    init(order: Order) {
        self.order = order
    }
    
    /**
    Set a custom var
    - parameter varId: custom var identifier
    - parameter value: custom var value
    - returns: the OrderCustomVar instance
    */
    public func add(varId: Int, value: String) ->  OrderCustomVar {
        let customVar = OrderCustomVar(varId: varId, value: value)
        
        list.append(customVar)
        
        return customVar
    }
}
