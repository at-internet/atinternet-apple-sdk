//
//  ScrollEventTests.swift
//  SmartTracker
//
//  Created by Théo Damaville on 17/11/2015.
//  Copyright © 2015 AT Internet. All rights reserved.
//

import XCTest

class ScrollEventTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        UIApplicationContext.sharedInstance.currentTouchedView = nil
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        UIApplicationContext.sharedInstance.currentTouchedView = nil
        super.tearDown()
    }

    func testInitializeScroll() {
        let direction = arc4random_uniform(2) > 0 ? ScrollEvent.ScrollDirection.Down : ScrollEvent.ScrollDirection.Up
        let aView = TestGenerator.randomViewGenerator()
        UIApplicationContext.sharedInstance.currentTouchedView = aView
        let scroll = ScrollEvent(view: View(), direction: direction, currentScreen: Screen())
        let expected:NSDictionary = [
            "event": "scroll",
            "data":[
                "type" : "scroll",
                "methodName" : "handleScroll:",
                "title": "handleScroll:",
                "direction" : direction.rawValue,
                "isDefaultMethod": true,
                "x" : -1,
                "y" : -1,
                "view": [
                    "className":aView.classLabel,
                    "height" : aView.frame.height,
                    "path" : aView.classLabel,
                    "position" : -1,
                    "screenshot" : "",
                    "text" : "",
                    "width" : aView.frame.width,
                    "visible":false,
                    "x" : 0,
                    "y" : 0,
                ],
                "screen":[
                    "title":"",
                    "className":"",
                    "scale":UIScreen.mainScreen().scale,
                    "width":UIScreen.mainScreen().bounds.size.width,
                    "height":UIScreen.mainScreen().bounds.size.height,
                    "app":[
                        "device":"x86_64",
                        "token":"",
                        "version":"",
                        "package":"",
                        "platform":"ios",
                    ],
                    "orientation":1
                ]
            ]
        ]
        XCTAssertEqual(scroll.description.toJSONObject() as? NSDictionary, expected)
    }
    
}
