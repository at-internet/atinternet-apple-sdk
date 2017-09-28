//
//  RotationEventTests.swift
//  SmartTracker
//
//  Created by Théo Damaville on 17/11/2015.
//  Copyright © 2015 AT Internet. All rights reserved.
//

import XCTest

class ScreenRotationEventTests: XCTestCase {

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

    func testInitializeRotation() {
        let orientations = [0,1,2,3,4,5,6].map( { UIDeviceOrientation.init(rawValue: $0) } )
        let orientation: UIDeviceOrientation? = orientations[Int(arc4random_uniform(UInt32(orientations.count)))]
        guard let _ = orientation else {
            return
        }
        let rotationEvent = ScreenRotationEvent(orientation: .portrait)
        let jsonObj: NSMutableDictionary = [
            "event": "screenRotation",
            "data":[
                "methodName": "rotate",
                "name": "",
                "className": "",
                "direction": UIViewControllerContext.UIViewControllerOrientation.portrait.rawValue,
                "type":"screen",
                "triggeredBy": "",
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
        
        XCTAssertEqual(jsonObj, rotationEvent.description.toJSONObject() as? NSDictionary)
    }
}
