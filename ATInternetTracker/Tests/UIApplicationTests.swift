//
//  UIApplicationTests.swift
//  SmartTracker
//
//  Created by Théo Damaville on 18/11/2015.
//  Copyright © 2015 AT Internet. All rights reserved.
//

import XCTest

class UIApplicationTests: XCTestCase {

    override func setUp() {
        super.setUp()
        UIApplicationContext.sharedInstance.currentTouchedView = nil
    }
    
    override func tearDown() {
        UIApplicationContext.sharedInstance.currentTouchedView = nil
        super.tearDown()
    }
    
    func testShouldSendNowWhenSegmentedControl() {
        let segmentedControl = UISegmentedControl()
        UIApplicationContext.sharedInstance.currentTouchedView = segmentedControl
        let b = UIApplication.sharedApplication().shouldSendNow()
        let expected = false
        XCTAssertEqual(expected, b)
    }
    
    func testShouldSendNowButton() {
        let but = UIButton()
        UIApplicationContext.sharedInstance.currentTouchedView = but
        let b = UIApplication.sharedApplication().shouldSendNow()
        let expected = false
        XCTAssertEqual(expected, b)
    }
}
