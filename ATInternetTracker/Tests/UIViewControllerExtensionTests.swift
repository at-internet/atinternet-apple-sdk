//
//  UIViewControllerExtensionTests.swift
//  SmartTracker
//
//  Created by Théo Damaville on 06/11/2015.
//  Copyright © 2015 AT Internet. All rights reserved.
//

import XCTest
import Tracker

class UIViewControllerExtensionTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testIgnoreListWhenAllowed() {
        let controller = UIViewController()
        XCTAssertFalse(controller.shouldIgnoreViewController())
    }
    
    func testIgnoreListWhenIgnored() {
        let controller = UINavigationController()
        XCTAssertTrue(controller.shouldIgnoreViewController())
    }
}