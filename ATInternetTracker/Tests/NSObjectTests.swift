//
//  NSObjectTests.swift
//  SmartTracker
//
//  Created by Théo Damaville on 16/11/2015.
//  Copyright © 2015 AT Internet. All rights reserved.
//

import XCTest

class NSObjectTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testClassLabel() {
        let arrayViews:[NSObject]  = [UIView(), UITextView(), UIImageView(), UISlider(), NSDictionary()]
        let arrayResult = ["UIView", "UITextView", "UIImageView", "UISlider", "NSDictionary"]
        XCTAssertEqual(arrayViews.map({ return $0.classLabel }), arrayResult)
    }
    
    func testHasPropertyWhenPropertyExists() {
        let v = UIView()
        XCTAssertTrue(v.at_hasProperty("layer"))
    }
    
    func testHasPropertyWhenPropertyDoesntExist(){
        let o = NSObject()
        XCTAssertFalse(o.at_hasProperty("coucou"))
    }
}
