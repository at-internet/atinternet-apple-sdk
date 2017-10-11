//
//  AppTests.swift
//  ATInternetTracker
//
//  Created by Théo Damaville on 25/09/2017.
//

import XCTest

class AppTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func keyExist () {
        
    }
    
    func testApp() {
        ATInternet.sharedInstance.defaultTracker.token = "-"
        ATInternet.sharedInstance.defaultTracker.setSiteId(410501, sync: true, completionHandler: nil)
        let app = App()
        let json = app.toJSONObject
        let keys = ["appIcon", "version", "device", "token", "package", "platform", "title", "width", "height", "scale", "screenOrientation", "name", "token", "siteID"]
        
        XCTAssert(json["event"]! as! String == "app")
        let d = json["data"] as! [String:Any]
        
        for k in keys {
            if let value = d[k] as? String {
                XCTAssert(!value.isEmpty)
            }
        }
    }
}
