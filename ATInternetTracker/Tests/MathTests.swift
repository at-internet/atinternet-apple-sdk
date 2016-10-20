//
//  MathTests.swift
//  SmartTracker
//
//  Created by Théo Damaville on 16/11/2015.
//  Copyright © 2015 AT Internet. All rights reserved.
//

import XCTest

class MathTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testPointSubstract() {
        let a = CGFloat(arc4random_uniform(100))
        let b = CGFloat(arc4random_uniform(100))
        let pa = CGPoint(x: a, y: b)
        let pb = CGPoint(x: a, y: b)
        let test = CGPoint.zero
        XCTAssertEqual(test, Maths.CGPointSub(pa, b: pb))
    }
    
    func testPointDistance() {
        let a = CGFloat(arc4random_uniform(100))
        let b = CGFloat(arc4random_uniform(100))
        let pa = CGPoint(x: a, y: b)
        let expected = sqrt( a*a + b*b )
        XCTAssertEqual(Maths.CGPointDist(CGPoint.zero, b: pa), expected)
    }
}
