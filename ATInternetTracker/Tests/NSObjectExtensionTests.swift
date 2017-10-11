//
//  NSObjectExtensionTests.swift
//  SmartTracker
//
//  Created by Théo Damaville on 06/11/2015.
//  Copyright © 2015 AT Internet. All rights reserved.
//

import Foundation

import XCTest
import Tracker

class NSObjectExtensionTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testClassLabelExtension() {
        let str   = "NSObject"
        let anObj = NSObject()
        
        let str2  = "UIImageView"
        let aView = UIImageView()
        
        XCTAssertEqual(anObj.classLabel, str)
        XCTAssertEqual(aView.classLabel, str2)
    }
}