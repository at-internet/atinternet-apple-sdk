//
//  EventManagerTests.swift
//  SmartTracker
//
//  Created by Théo Damaville on 06/11/2015.
//  Copyright © 2015 AT Internet. All rights reserved.
//

import Foundation

import XCTest
import Tracker

class EventManagerTests: XCTestCase {
    
    override func setUp() {
        /**
        We clean up the queue manager before any test
        Since we can't clean manually, we have to cancel everything + wait all op to finish/be canceled
        */
        super.setUp()
        EventManager.sharedInstance.cancelAllEvents()
        NSThread.sleepForTimeInterval(0.4)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCancelLastScreenWhenEventIsScreen() {
        let s   = ScreenEvent(title: "hello", className: "coucou", triggeredBy: nil)
        let sop = ScreenOperation(screenEvent: s)
        EventManager.sharedInstance.addEvent(sop)
        EventManager.sharedInstance.cancelLastScreenEvent()
        let optOp:NSOperation? = EventManager.sharedInstance.lastEvent()
        XCTAssertNotNil(optOp)
        if let op = optOp {
            XCTAssertTrue(op.cancelled)
        }
    }
    
    func testCancelLastScreenWhenEventIsNotScreen() {
        /// Adding an other subclass of NSOperation
        let bo = NSBlockOperation { () -> Void in
            NSThread.sleepForTimeInterval(2)
        }
        EventManager.sharedInstance.addEvent(bo)
        EventManager.sharedInstance.cancelLastScreenEvent()
        let optOp:NSOperation? = EventManager.sharedInstance.lastEvent()
        XCTAssertNotNil(optOp)
        if let op = optOp {
            XCTAssertFalse(op.cancelled)
        }
    }
}