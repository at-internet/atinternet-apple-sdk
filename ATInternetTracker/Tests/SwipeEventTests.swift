//
//  SwipeEventTests.swift
//  SmartTracker
//
//  Created by Théo Damaville on 17/11/2015.
//  Copyright © 2015 AT Internet. All rights reserved.
//

import XCTest

class SwipeEventTests: XCTestCase {

    override func setUp() {
        super.setUp()
        UIApplicationContext.sharedInstance.currentTouchedView = nil
    }
    
    override func tearDown() {
        UIApplicationContext.sharedInstance.currentTouchedView = nil
        super.tearDown()
    }

    func testInitializeSwipe() {
        let aView = TestGenerator.randomViewGenerator()
        UIApplicationContext.sharedInstance.currentTouchedView = aView
        let direction = arc4random_uniform(2) > 0 ? SwipeEvent.SwipeDirection.Left : SwipeEvent.SwipeDirection.Right
        let swipe = SwipeEvent(view: View(), direction: direction, currentScreen: Screen(), methodName: "handleSwipe:")
        let expected:NSDictionary = [
            "event": "swipe",
            "data":[
                "type" : "swipe",
                "title" : "handleSwipe:",
                "methodName" : "handleSwipe:",
                "direction" : direction.rawValue,
                "isDefaultMethod": false,
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
                    "scale":UIScreen.main.scale,
                    "width":UIScreen.main.bounds.size.width,
                    "height":UIScreen.main.bounds.size.height,
                    "app":[
                        "device":"x86_64",
                        "token":"-",
                        "package":"noApplicationIdentifier",
                        "version":"",
                        "platform":"ios",
                    ],
                    "orientation":1
                ]
            ]
        ]
        XCTAssertEqual(swipe.description.toJSONObject() as? NSDictionary, expected)
        
    }
}
