//
//  ScreenTests.swift
//  SmartTracker
//
//  Created by Théo Damaville on 17/11/2015.
//  Copyright © 2015 AT Internet. All rights reserved.
//

import XCTest

class ScreenObjectTests: XCTestCase {

    override func setUp() {
        super.setUp()
        UIViewControllerContext.sharedInstance.activeViewControllers.removeAll()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        UIViewControllerContext.sharedInstance.activeViewControllers.removeAll()
        super.tearDown()
    }

    func testInitialise() {
        let viewController = UIViewController()
        viewController.title = "Hello Controller"
        UIViewControllerContext.sharedInstance.activeViewControllers.append(viewController)
        
        let screen = Screen()
        let expectedJSON: NSDictionary = [
            "screen":[
                "title": "UIViewController", // className
                "className": "UIViewController",
                "scale": UIScreen.mainScreen().scale,
                "width": UIScreen.mainScreen().bounds.width,
                "height": UIScreen.mainScreen().bounds.height,
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
        XCTAssertEqual(screen.description.toJSONObject() as? NSDictionary, expectedJSON)
        XCTAssertEqual(screen.name, viewController.title)
    }
}
