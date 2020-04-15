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
//  ECommerce.swift
//  Tracker
//
import Foundation

public class ECommerce: NSObject {
    private var tracker : Tracker
    private var events : Events
    
    @objc public lazy var displayPageProducts: DisplayPageProducts = DisplayPageProducts(events: self.events)
    
    @objc public lazy var displayProducts: DisplayProducts = DisplayProducts(events: self.events)
    
    @objc public lazy var addProducts: AddProducts = AddProducts(events: self.events)
    
    @objc public lazy var removeProducts: RemoveProducts = RemoveProducts(events: self.events)
    
    @objc public lazy var displayCarts: DisplayCarts = DisplayCarts(events: self.events)
    
    @objc public lazy var updateCarts: UpdateCarts = UpdateCarts(events: self.events)
    
    @objc public lazy var deliveryCheckouts: DeliveryCheckouts = DeliveryCheckouts(events: self.events)
    
    @objc public lazy var paymentCheckouts: PaymentCheckouts = PaymentCheckouts(events: self.events)
    
    @objc public lazy var cartAwaitingPayments: CartAwaitingPayments = CartAwaitingPayments(events: self.events)
    
    @objc public lazy var transactionConfirmations: TransactionConfirmations = TransactionConfirmations(events: self.events)
    
    init(tracker: Tracker) {
        self.tracker = tracker
        self.events = tracker.events
    }
    
    /// Enable automatic sales tracker
    ///
    /// - Parameters:
    ///   - enabled: /
    ///   - sync: perform the operation synchronously (optional, default: false)
    ///   - completionHandler: called when the operation has been done
    @available(*, deprecated, message: "since 2.17.0, configuration is unused")
    @objc public func setAutoSalesTrackerEnabled(_ enabled: Bool, sync: Bool = false, completionHandler: ((_ isSet: Bool) -> Void)?) {
        tracker.delegate?.warningDidOccur?("Useless method")
    }
    
    /// Set a new collect domain
    ///
    /// - Parameters:
    ///   - domain: the new domain
    ///   - sync: perform the operation synchronously (optional, default: false)
    ///   - completionHandler: called when the operation has been done
    /// - Deprecated : Since 2.16.0, default log domain used
    @objc @available(*, deprecated, message: "since 2.16.0, default log domain used")
    public func setCollectDomain(_ domain: String, sync: Bool = false, completionHandler: ((_ isSet: Bool) -> Void)?) {
        tracker.delegate?.warningDidOccur?("Useless method, default log domain used")
    }
}
