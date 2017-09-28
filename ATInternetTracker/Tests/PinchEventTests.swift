//
//  PinchEventTests.swift
//  SmartTracker
//
//  Created by Théo Damaville on 17/11/2015.
//  Copyright © 2015 AT Internet. All rights reserved.
//

import XCTest

class PinchEventTests: XCTestCase {

    override func setUp() {
        super.setUp()
        UIApplicationContext.sharedInstance.currentTouchedView = nil
    }
    
    override func tearDown() {
        UIApplicationContext.sharedInstance.currentTouchedView = nil
        super.tearDown()
    }

    func testExample() {
        let aView = TestGenerator.randomViewGenerator()
        UIApplicationContext.sharedInstance.currentTouchedView = aView
        
        let direction = arc4random_uniform(2) > 0 ? PinchEvent.PinchDirection.In : PinchEvent.PinchDirection.Out
        let pinch = PinchEvent(view: View(), direction: direction, currentScreen: Screen(), methodName: "handlePinch:")
        let expected:NSDictionary = [
            "event": "pinch",
            "data":[
                "type" : "pinch",
                "methodName" : "handlePinch:",
                "title": "handlePinch:",
                "direction" : direction.rawValue,
                "isDefaultMethod": false,
                "x":-1,
                "y":-1,
                "view": [
                    "className":aView.classLabel,
                    "x":0,
                    "y":0,
                    "width":aView.frame.size.width,
                    "height":aView.frame.size.height,
                    "text":"",
                    "screenshot":"",
                    "path":aView.classLabel,
                    "visible":false,
                    "position":-1
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
                        "version":"",
                        "package":"noApplicationIdentifier",
                        "platform":"ios"
                    ],
                    "orientation":1
                ]
            ]
        ]
        
        XCTAssertEqual(pinch.description.toJSONObject() as? NSDictionary, expected)
    }
}
