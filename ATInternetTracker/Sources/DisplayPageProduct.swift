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
    
    /// Product property
    @objc public lazy var product : ECommerceProduct = ECommerceProduct()
    
    override var data: [String : Any] {
        get {
            let productProps = product.getProps()
            if !productProps.isEmpty {
                _data["product"] = productProps
            }
            return super.data
        }
        set {
            _data = newValue
        }
    }
    
    init() {
        super.init(name: "product.page_display")
    }
}

/// Wrapper class to manage DisplayPageProducts event instances
public class DisplayPageProducts : EventsHelper {
    
    override init(events: Events) {
        super.init(events: events)
    }
    
    /// Add display page product event tracking
    ///
    /// - Returns: DisplayPageProduct instance
    @objc public func add() -> DisplayPageProduct {
        let dpp = DisplayPageProduct()
        _ = events.add(event: dpp)
        return dpp
    }
    
    /// Add display page product event tracking
    ///
    /// - Parameter screenLabel: a screen label
    /// - Returns: DisplayPageProduct instance
    @available(*, deprecated, message: "Use 'add()' method instead")
    @objc public func add(screenLabel: String?) -> DisplayPageProduct {
        return add()
    }
    
    /// Add display page product event tracking
    ///
    /// - Parameter screen: a screen instance
    /// - Returns: DisplayPageProduct instance
    @available(*, deprecated, message: "Use 'add()' method instead")
    @objc public func add(screen: Screen?) -> DisplayPageProduct {
        return add()
    }
}
