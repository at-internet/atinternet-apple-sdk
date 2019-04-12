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
//  DisplayPageProduct.swift
//  Tracker
//
import Foundation

/// Wrapper class for DisplayPageProduct event tracking (SalesInsight)
public class DisplayProduct: Event {
    
    /// List property
    @objc public lazy var products : [ECommerceProduct] = [ECommerceProduct]()
    
    private var tracker : Tracker
    
    override var data: [String : Any] {
        get {
            return _data
        }
    }
    
    init(tracker: Tracker) {
        self.tracker = tracker
        super.init(type: "product.display")
    }
    
    @objc public func setProducts(products: [ECommerceProduct]) {
        self.products = products
    }
    
    override func getAdditionalEvents() -> [Event] {
        var generatedEvents = super.getAdditionalEvents()
        
        for p in products {
            /// SALES INSIGHTS
            let dp = DisplayProduct(tracker: tracker)
            dp._data["product"] = p.properties
            generatedEvents.append(dp)
        }
        
        /// SALES TRACKER
        if let autoSalesTrackerStr = tracker.configuration.parameters[TrackerConfigurationKeys.AutoSalesTracker], autoSalesTrackerStr.toBool() {
            
            for p in products {
                var stProductId : String
                if let name = p.get(key: "s:$") {
                    stProductId = String(format: "%@[%@]", String(describing: p.get(key: "s:id") ?? ""), String(describing: name))
                } else {
                    stProductId = String(describing: p.get(key: "s:id") ?? "")
                }
                
                let stProduct = tracker.products.add(stProductId)
                
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
            tracker.products.sendViews()
        }
        
        return generatedEvents
    }
}

/// Wrapper class to manage DisplayProducts event instances
public class DisplayProducts : EventsHelper {
    
    private let tracker : Tracker
    
    init(events: Events, tracker: Tracker) {
        self.tracker = tracker
        super.init(events: events)
    }
    
    /// Add display products event tracking
    ///
    /// - Returns: DisplayProduct instance
    @objc public func add() -> DisplayProduct {
        let dp = DisplayProduct(tracker: tracker)
        _ = events.add(event: dp)
        return dp
    }
}
