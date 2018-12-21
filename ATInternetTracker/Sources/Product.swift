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
//  Product.swift
//  Tracker
//

import Foundation

/// Wrapper class for tracking product
public class Product : BusinessObject {
    lazy var _customObjects: [String: CustomObject] = [String: CustomObject]()
    
    /// Actions
    @objc public enum ProductAction: Int {
        case view = 0
    }
    
    /// Product identifier
    @objc public var productId: String = ""
    
    /// First Product category
    @objc public var category1: String?
    
    // Second Product category
    @objc public var category2: String?
    
    // Third Product category
    @objc public var category3: String?
    
    // Fourth Product category
    @objc public var category4: String?
    
    // Fifth Product category
    @objc public var category5: String?
    
    // Sixth Product category
    @objc public var category6: String?
    
    /// Product quantity
    @objc public var quantity: Int = -1
    
    /// Product unit price with tax
    @objc public var unitPriceTaxIncluded: Double = -1
    
    /// Product unit price without tax
    @objc public var unitPriceTaxFree: Double = -1
    
    /// Discount value with tax
    @objc public var discountTaxIncluded: Double = -1
    
    /// Discount value without tax
    @objc public var discountTaxFree: Double = -1
    
    /// Promotional code
    @objc public var promotionalCode: String?
    
    /// Action
    @objc public var action: ProductAction = ProductAction.view
    
    // Custom objects to add to product hit
    @objc public lazy var customObjects: CustomObjects = CustomObjects(product: self)
    
    fileprivate func getProductActionRawValue(_ value: Int) -> String {
        switch value {
        case 0:
            return "view"
        default:
            return "view"
        }
    }
    
    /// Set parameters in buffer
    override func setParams() {
        _ = tracker.setParam(HitParam.hitType.rawValue, value: "pdt")
        
        for (_, value) in _customObjects {
            value.tracker = self.tracker
            value.setParams()
        }
        
        let option = ParamOption()
        option.append = true
        option.encode = true
        option.separator = "|"
        
        _ = tracker.setParam("pdtl", value: buildProductName(), options: option)
    }
    
    //MARK: Screen name building
    func buildProductName() -> String {
        var productName = category1 == nil ? "" : category1! + "::"
        productName = category2 ==  nil ? productName : productName + category2! + "::"
        productName = category3 ==  nil ? productName : productName + category3! + "::"
        productName = category4 ==  nil ? productName : productName + category4! + "::"
        productName = category5 ==  nil ? productName : productName + category5! + "::"
        productName = category6 ==  nil ? productName : productName + category6! + "::"
        productName += productId
        
        return productName
    }
    
    /// Send products view hit
    @objc public func sendView() {
        self.action = ProductAction.view
        self.tracker.dispatcher.dispatch([self])
    }
}

/// Wrapper class to manage Product instances
public class Products: NSObject {
    
    /// Cart instance
    var cart: Cart!
    
    /// Tracker instance
    var tracker: Tracker!
    
    /**
    CartProducts initializer
    - parameter cart: the cart instance
    - returns: CartProducts instance
    */
    init(cart: Cart) {
        self.cart = cart
    }
    
    /**
    Screens initializer
    - parameter tracker: the tracker instance
    - returns: Screens instance
    */
    init(tracker: Tracker) {
        self.tracker = tracker
    }
    
    /**
    Add a product
    - parameter product: a product instance
    - returns: the product added
    */
    @objc public func add(_ product: Product) -> Product {
        if(cart != nil) {
            cart.productList.append(product)
        } else {
            tracker.businessObjects[product.id] = product
        }
        
        return product
    }
    
    /**
    Add a product
    - parameter productId: the product identifier
    - returns: the new product instance
    */
    @objc(addString:)
    public func add(_ productId: String) -> Product {
        let product = Product(tracker: cart != nil ? cart.tracker : tracker)
        product.productId = productId
        
        if(cart != nil) {
            cart.productList.append(product)
        } else {
            tracker.businessObjects[product.id] = product
        }
        
        return product
    }
    
    /// Add a product
    ///
    /// - Parameters:
    ///   - productId: the product identifier
    ///   - category1: category1 label
    /// - Returns: the new product instance
    @objc public func add(_ productId: String, category1: String) -> Product {
        let pdt = add(productId)
        pdt.category1 = category1
        return pdt
    }
    
    /// Add a product
    ///
    /// - Parameters:
    ///   - productId: the product identifier
    ///   - category1: category1 label
    ///   - category2: category2 label
    /// - Returns: the new product instance
    @objc public func add(_ productId: String, category1: String, category2: String) -> Product {
        let pdt = add(productId)
        pdt.category1 = category1
        pdt.category2 = category2
        return pdt
    }
    
    /// Add a product
    ///
    /// - Parameters:
    ///   - productId: the product identifier
    ///   - category1: category1 label
    ///   - category2: category2 label
    ///   - category3: category3 label
    /// - Returns: the new product instance
    @objc public func add(_ productId: String, category1: String, category2: String, category3: String) -> Product {
        let pdt = add(productId)
        pdt.category1 = category1
        pdt.category2 = category2
        pdt.category3 = category3
        return pdt
    }
    
    /// Add a product
    ///
    /// - Parameters:
    ///   - productId: the product identifier
    ///   - category1: category1 label
    ///   - category2: category2 label
    ///   - category3: category3 label
    ///   - category4: category4 label
    /// - Returns: the new product instance
    @objc public func add(_ productId: String, category1: String, category2: String, category3: String, category4: String) -> Product {
        let pdt = add(productId)
        pdt.category1 = category1
        pdt.category2 = category2
        pdt.category3 = category3
        pdt.category4 = category4
        return pdt
    }
    
    /// Add a product
    ///
    /// - Parameters:
    ///   - productId: the product identifier
    ///   - category1: category1 label
    ///   - category2: category2 label
    ///   - category3: category3 label
    ///   - category4: category4 label
    ///   - category5: category5 label
    /// - Returns: the new product instance
    @objc public func add(_ productId: String, category1: String, category2: String, category3: String, category4: String, category5: String) -> Product {
        let pdt = add(productId)
        pdt.category1 = category1
        pdt.category2 = category2
        pdt.category3 = category3
        pdt.category4 = category4
        pdt.category5 = category5
        return pdt
    }
    
    /// Add a product
    ///
    /// - Parameters:
    ///   - productId: the product identifier
    ///   - category1: category1 label
    ///   - category2: category2 label
    ///   - category3: category3 label
    ///   - category4: category4 label
    ///   - category5: category5 label
    ///   - category6: category6 label
    /// - Returns: the new product instance
    @objc public func add(_ productId: String, category1: String, category2: String, category3: String, category4: String, category5: String, category6: String) -> Product {
        let pdt = add(productId)
        pdt.category1 = category1
        pdt.category2 = category2
        pdt.category3 = category3
        pdt.category4 = category4
        pdt.category5 = category5
        pdt.category6 = category6
        return pdt
    }

    /// Remove a product
    ///
    /// - Parameter productId: the product identifier
    @objc public func remove(_ productId: String) {
        if(cart != nil) {
            var index = -1
            for (i, p) in cart.productList.enumerated() {
                if p.productId == productId {
                    index = i
                    break
                }
            }
            if index != -1 {
                cart.productList.remove(at: index)
            }
        } else {
            for(_,value) in self.tracker.businessObjects {
                if (value is Product && (value as! Product).productId == productId) {
                    self.tracker.businessObjects.removeValue(forKey: value.id)
                    break
                }
            }
        }
    }

    /// Remove all the products
    @objc public func removeAll() {
        if(cart != nil) {
            cart.productList.removeAll(keepingCapacity: false)
        } else {
            for(_,value) in self.tracker.businessObjects {
                if (value is Product) {
                    self.tracker.businessObjects.removeValue(forKey: value.id)
                }
            }
        }
    }

    /// Send viewed products
    @objc public func sendViews() {
        var impressions = [BusinessObject]()
        
        for(_,object) in self.tracker.businessObjects {
            if(object is Product) {
                impressions.append(object)
            }
        }
        
        let sortedImpressions = impressions.sorted {
            a, b in return a.timeStamp < b.timeStamp
        }
        
        if(sortedImpressions.count > 0) {
            self.tracker.dispatcher.dispatch(sortedImpressions)
        }
    }
}
