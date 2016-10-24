//
//  PanEventTests.swift
//  SmartTracker
//
//  Created by Théo Damaville on 17/11/2015.
//  Copyright © 2015 AT Internet. All rights reserved.
//

import XCTest

class PanEventTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testInitialize() {
        let aView = TestGenerator.randomViewGenerator()
        UIApplicationContext.sharedInstance.currentTouchedView = aView
        let directions = [PanEvent.PanDirection.Left, PanEvent.PanDirection.Right, PanEvent.PanDirection.Up, PanEvent.PanDirection.Down]
        let direction = directions[Int(arc4random_uniform(UInt32(directions.count)))]
        let pan = PanEvent(view: View(), direction: direction, currentScreen: Screen())
        let expected:NSDictionary = [
            "event": "pan",
            "data":[
                "type" : "pan",
                "methodName" : "handlePan:",
                "title" : "handlePan:",
                "direction" : direction.rawValue,
                "isDefaultMethod": true,
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
                    "position":-1,
                    "visible":false
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
                        "platform":"ios"
                    ],
                    "orientation":1
                ],
            ]
        ]
        XCTAssertEqual(expected, pan.description.toJSONObject() as? NSDictionary)
    }
}
