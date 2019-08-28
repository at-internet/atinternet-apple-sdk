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
public class DisplayPageProduct: Event {
    
    private var tracker : Tracker
    
    /// Product property
    @objc public lazy var product : ECommerceProduct = ECommerceProduct()
    
    override var data: [String : Any] {
        get {
            if !product.properties.isEmpty {
                _data["product"] = product.properties
            }
            return super.data
        }
    }
    
    init(tracker: Tracker) {
        self.tracker = tracker
        super.init(name: "product.page_display")
    }
    
    override func getAdditionalEvents() -> [Event] {
        /// SALES TRACKER
        if let autoSalesTrackerStr = tracker.configuration.parameters[TrackerConfigurationKeys.AutoSalesTracker], autoSalesTrackerStr.toBool() {
            
            var stProductId : String
            if let name = product.get(key: "s:$") {
                stProductId = String(format: "%@[%@]", String(describing: product.get(key: "s:id") ?? ""), String(describing: name))
            } else {
                stProductId = String(describing: product.get(key: "s:id") ?? "")
            }
            
            let stProduct = tracker.products.add(stProductId)
            
            if let category1 = product.get(key: "s:category1") {
                stProduct.category1 = String(format: "[%@]", String(describing: category1))
            }
            
            if let category2 = product.get(key: "s:category2") {
                stProduct.category2 = String(format: "[%@]", String(describing: category2))
            }
            
            if let category3 = product.get(key: "s:category3") {
                stProduct.category3 = String(format: "[%@]", String(describing: category3))
            }
            
            if let category4 = product.get(key: "s:category4") {
                stProduct.category4 = String(format: "[%@]", String(describing: category4))
            }
            
            if let category5 = product.get(key: "s:category5") {
                stProduct.category5 = String(format: "[%@]", String(describing: category5))
            }
            
            if let category6 = product.get(key: "s:category6") {
                stProduct.category6 = String(format: "[%@]", String(describing: category6))
            }
            
            stProduct.sendView()
        }
        
        return super.getAdditionalEvents()
    }
}

/// Wrapper class to manage DisplayPageProducts event instances
public class DisplayPageProducts : EventsHelper {
    
    private let tracker : Tracker
    
    init(events: Events, tracker: Tracker) {
        self.tracker = tracker
        super.init(events: events)
    }
    
    /// Add display page product event tracking
    ///
    /// - Returns: DisplayPageProduct instance
    @objc public func add() -> DisplayPageProduct {
        let dp = DisplayPageProduct(tracker: tracker)
        _ = events.add(event: dp)
        return dp
    }
}
