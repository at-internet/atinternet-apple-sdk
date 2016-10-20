//
//  ViewTests.swift
//  SmartTracker
//
//  Created by Théo Damaville on 16/11/2015.
//  Copyright © 2015 AT Internet. All rights reserved.
//

import XCTest

class ViewTests: XCTestCase {

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

    func testInitViewWhenContextEmpty() {
        let v = View()
        let jsonObj = v.description.toJSONObject()
        let expectedJsonObj:NSDictionary = [
            "view":[
                "className": "",
                "x": 0,
                "y": 0,
                "width": 0,
                "height": 0,
                "text": "",
                "screenshot": "",
                "path":"",
                "visible":true,
                "position":-1,
            ]
        ]
        XCTAssertEqual(jsonObj as? NSDictionary, expectedJsonObj)
    }
    
    
    func testInitViewWhenContextInitialized() {
        let testView = TestGenerator.randomViewGenerator()
        UIApplicationContext.sharedInstance.currentTouchedView = testView
        let v = View()
        let jsonObj = v.description.toJSONObject()
        let expectedJsonObj:NSDictionary = [
            "view":[
                "className": testView.classLabel,
                "x": 0,
                "y": 0,
                "width": testView.frame.size.width,
                "height": testView.frame.size.height,
                "text": "",
                "screenshot": "",
                "path":testView.classLabel,
                "visible":false,
                "position":-1
            ]
        ]
        
        XCTAssertEqual(jsonObj as? NSDictionary, expectedJsonObj)
    }
    
    func testInitViewWhenContextInitialized2() {
        
        
        let testView = UITextView(frame: CGRect(x: 10, y: 20, width: 100, height: 150))
        testView.text = "Testing text"
        UIApplicationContext.sharedInstance.currentTouchedView = testView
        UIApplicationContext.sharedInstance.initialTouchPosition = CGPoint(x: 11, y: 21)
        let v = View()
        let jsonObj = v.description.toJSONObject()
        let expectedJsonObj:NSDictionary = [
            "view":[
                "className": "UITextView",
                "x": 0,
                "y": 0,
                "width": 100,
                "height": 150,
                "text": "Testing text",
                "screenshot": "",
                "path":"UITextView",
                "visible":false,
                "position":-1
            ]
        ]
        
        XCTAssertEqual(jsonObj as? NSDictionary, expectedJsonObj)
    }
}
