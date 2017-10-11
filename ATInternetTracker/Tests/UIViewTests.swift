//
//  UIViewTests.swift
//  SmartTracker
//
//  Created by Théo Damaville on 17/11/2015.
//  Copyright © 2015 AT Internet. All rights reserved.
//

import XCTest

class UIViewTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testIsChildOfScrollview() {
        let scrollView = UIScrollView()
        let aChild = TestGenerator.randomViewGenerator()
        let subChild = TestGenerator.randomViewGenerator()
        aChild.addSubview(subChild)
        scrollView.addSubview(aChild)
        XCTAssertTrue(scrollView.isInScrollView)
        XCTAssertTrue(subChild.isInScrollView)
        XCTAssertTrue(aChild.isInScrollView)
    }
    
    func testIsNotChildOfScrollView() {
        let child = TestGenerator.randomViewGenerator( { return (!$0.isKind(of: UIScrollView.self)) } )
        XCTAssertFalse(child.isInScrollView)
    }
    
    func testFindTextInTextField() {
        let keyword = "Hello world"
        
        let tf = UITextField()
        tf.attributedText = NSAttributedString(string: keyword)
        XCTAssertTrue( tf.textValue == keyword )
    }
    
    func testFindTextInTextView() {
        let keyword = "hello"
        let tv = UITextView()
        tv.attributedText = NSAttributedString(string: keyword)
    }
    
    func testFindTextInButton() {
        let b = UIButton()
        b.frame = CGRect(x: 0,y: 0,width: 320,height: 568)
        b.setTitle("hello world", for: UIControlState())
        let window = UIWindow()
        window.addSubview(b)
        XCTAssertTrue(b.textValue == "hello world")
    }
    
    func testHasGestureRecognizerWithUIControl() {
        let b = TestGenerator.randomViewGenerator({
            if let _ = $0 as? UIControl {
                return true
            } else {
                return false
            }
        })
        XCTAssertFalse(b.hasActiveGestureRecognizer)
    }
    
    func testHasGestureRecognizerWithoutUIControl() {
        let search = UISearchBar()
        XCTAssertTrue(search.hasActiveGestureRecognizer)
        
        let tv = UITextView()
        XCTAssertTrue(tv.hasActiveGestureRecognizer)
    }
}
