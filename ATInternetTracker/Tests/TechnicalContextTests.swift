/*
This SDK is licensed under the MIT license (MIT)
Copyright (c) 2015- Applied Technologies Internet SAS (registration number B 403 261 258 - Trade and Companies Register of Bordeaux – France)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/





//
//  TechnicalContextTests.swift
//  Tracker
//

import UIKit
import XCTest

class TechnicalContextTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    /* On test les différentes possiblités de récupération d'un id client */
    
    func testIDFV() {
        let ref = UIDevice.current.identifierForVendor!.uuidString
        XCTAssertNotNil(ref, "IDFV shall not be nil")
        XCTAssertEqual(ref, TechnicalContext.userId("idfv", ignoreLimitedAdTracking: false, uuidDuration: 0, uuidExpirationMode: ""), "Unique identifier shall be equal to IDFV")
    }
    
    func testVersion() {
        let testBundle = Bundle.tracker
        if let url = testBundle.url(forResource: "Info", withExtension: "plist"),
            let myDict = NSDictionary(contentsOf: url) as? [String : Any] {
            let v = TechnicalContext.sdkVersion
            XCTAssertEqual(v, myDict["CFBundleShortVersionString"] as! String, "version is incorrect")
        }
    }
    
    func testNonExistingUUID() {
        UserDefaults.standard.removeObject(forKey: "ATApplicationUniqueIdentifier")
        UserDefaults.standard.synchronize()
        XCTAssertEqual(36, TechnicalContext.userId("whatever", ignoreLimitedAdTracking: false, uuidDuration: 0, uuidExpirationMode: "").count, "Unique identifier shall be a new valid UUID")
    }
    
    func testUserIdWithNilConfiguration() {
        UserDefaults.standard.removeObject(forKey: "ATApplicationUniqueIdentifier")
        UserDefaults.standard.synchronize()
        XCTAssertEqual(36, TechnicalContext.userId(nil, ignoreLimitedAdTracking: false, uuidDuration: 0, uuidExpirationMode: "").count, "Unique identifier shall be a new valid UUID")
    }
    
    func testSDKVersion() {
        XCTAssertNotNil(TechnicalContext.sdkVersion, "SDK version shall not be nil")
        XCTAssertNotEqual("", TechnicalContext.sdkVersion, "SDK version shall not have an empty string value")
    }
    
    func testLanguage() {
        XCTAssertNotNil(TechnicalContext.language, "Language shall not be nil")
        XCTAssertNotEqual("", TechnicalContext.language, "Language shall not have an empty string value")
    }
    
    func testDevice() {
        XCTAssertNotNil(TechnicalContext.device, "Device shall not be nil")
        XCTAssertNotEqual("", TechnicalContext.device, "Device shall not have an empty string value")
    }
    
    func testApplicationIdentifier() {
        XCTAssertNotNil(TechnicalContext.applicationIdentifier, "Application identifier shall not be nil")
    }
    
    func testApplicationVersion() {
        XCTAssertNotNil(TechnicalContext.applicationVersion, "Application version shall not be nil")
    }
    
    func testLocalHour() {
        XCTAssertNotNil(TechnicalContext.localHour, "Local hour shall not be nil")
        XCTAssertNotEqual("", TechnicalContext.localHour, "Local hour shall not have an empty string value")
    }
    
    func testScreenResolution() {
        XCTAssertNotNil(TechnicalContext.screenResolution, "Screen resolution shall not be nil")
        XCTAssertNotEqual("", TechnicalContext.screenResolution, "Screen resolution shall not have an empty string value")
    }
    
    func testCarrier() {
        #if os(iOS)
        XCTAssertNotNil(TechnicalContext.carrier, "Carrier shall not be nil")
        #else
        XCTAssertNotNil("Carrier")
        #endif
    }
    
    func testConnectionType() {
        XCTAssertNotNil(TechnicalContext.connectionType.rawValue, "Connection type shall not be nil")
        XCTAssertNotEqual("", TechnicalContext.connectionType.rawValue, "Connection type shall not have an empty string value")
    }
}
