//
//  ScreenEventTest.swift
//
//  Created by Théo Damaville on 02/11/2015.
//  Copyright © 2015 AT Internet. All rights reserved.
//

import XCTest
import Tracker

class ScreenEventTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInitialise() {
        let se = ScreenEvent(title: "view title", className: "TestUIViewController", triggeredBy: nil)
        XCTAssertEqual(se.screen.name, "view title")
        XCTAssertEqual(se.methodName, "viewDidAppear")
        XCTAssertEqual(se.direction, "appear")
        XCTAssertEqual(se.screen.className, "TestUIViewController")
    }
    
    func testDescription() {
        let se = ScreenEvent(title: "Accueil", className: "HelloViewController", triggeredBy: nil)
        let jsonObj:NSDictionary = [
            "event":"viewDidAppear",
            "data":[
                "methodName":"viewDidAppear",
                "direction" :"appear",
                "triggeredBy": "",
                "type":"screen",
                "screen":[
                    "title": "", // screenEvent remplit screen.name
                    "className": "HelloViewController",
                    "scale": UIScreen.main.scale,
                    "width": UIScreen.main.bounds.width,
                    "height": UIScreen.main.bounds.height,
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
        do {
            let json = try JSONSerialization.jsonObject(
                with: se.description.data(using: String.Encoding.utf8)!,
                options: JSONSerialization.ReadingOptions.allowFragments
            )
            XCTAssertEqual(json as? NSDictionary, jsonObj)
        } catch {}
    }
}
