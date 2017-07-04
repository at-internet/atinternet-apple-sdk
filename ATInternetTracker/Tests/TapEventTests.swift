//
//  TapEventTests.swift
//  SmartTracker
//
//  Created by Théo Damaville on 16/11/2015.
//  Copyright © 2015 AT Internet. All rights reserved.
//

import XCTest

class TapEventTests: XCTestCase {

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
        // setting up a random view
        let aView = TestGenerator.randomViewGenerator()
        let (x, y, w, h) = (aView.frame.origin.x, aView.frame.origin.y, aView.frame.size.width,aView.frame.size.height)
        let tx = arc4random_uniform(UInt32(w)) + UInt32(x)
        let ty = arc4random_uniform(UInt32(h)) + UInt32(y)
        let dir = arc4random_uniform(2) > 0 ? "single" : "double"
        
        UIApplicationContext.sharedInstance.currentTouchedView = aView
        
        
        
        let expectedMethod = UIApplicationContext.sharedInstance.getDefaultViewMethod(aView)
        //print(" --------------- " + (expectedMethod == nil ? "" : expectedMethod!) + " --------------")
        let te = TapEvent(x: Float(tx), y: Float(ty), view: View(), direction: dir, currentScreen: Screen(), methodName: expectedMethod)
        
        let expected:NSDictionary = [
            "event": "tap",
            "data":[
                "x" : Int(tx),
                "y" : Int(ty),
                "type" : "tap",
                "methodName" : expectedMethod ?? "handleTap:",
                "title": expectedMethod ?? "handleTap:",
                "direction" : dir,
                "isDefaultMethod": true,
                "view": [
                    "className":aView.classLabel,
                    "x":0,
                    "y":0,
                    "width":w,
                    "height":h,
                    "text":"",
                    "screenshot":"",
                    "path":aView.classLabel,
                    "position":-1,
                    "visible":false
                ],
                "screen":[
                    "title":"",
                    "className":"",
                    "scale":UIScreen.main.scale,
                    "width":UIScreen.main.bounds.size.width,
                    "height":UIScreen.main.bounds.size.height,
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
        
        //XCTAssertEqual(te.description.toJSONObject() as? NSDictionary, expected)
    }
}
