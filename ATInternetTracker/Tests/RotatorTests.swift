//
//  RotatorTests.swift
//  SmartTracker
//
//  Created by Théo Damaville on 25/11/2015.
//  Copyright © 2015 AT Internet. All rights reserved.
//

import XCTest

class RotatorTest: XCTestCase {
    override func setUp() {
        super.setUp()
        UIApplicationContext.sharedInstance.currentTouchedView = nil
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        UIApplicationContext.sharedInstance.currentTouchedView = nil
        super.tearDown()
    }

    func testInit() {
        let p0 = CGPointMake(0,0)
        let p1 = CGPointMake(30,30)
        let rotator = Rotator(p1: p0, p2: p1)
        XCTAssertNil(rotator.initialRotation)
        XCTAssertFalse(rotator.isValidRotation())
        XCTAssertEqual(p0, rotator.initialPoints.0)
        XCTAssertEqual(p1, rotator.initialPoints.1)
        XCTAssertEqual(p0, rotator.currentPoints.0)
        XCTAssertEqual(p1, rotator.currentPoints.1)
        XCTAssertEqual(rotator.getCurrentRotation(), 0)
    }
    
    func testIsRotation() {
        let p0 = CGPointMake(0,0)
        let p1 = CGPointMake(30,30)
        
        let rotator = Rotator(p1: p0, p2: p1)
        rotator.setCurrentPoints(CGPointMake(-10,0), p2: CGPointMake(40,20))
        rotator.setCurrentPoints(CGPointMake(0,30), p2: CGPointMake(30,-20))
        print(rotator.getCurrentRotation())
        XCTAssertTrue(rotator.isValidRotation())
    }
}