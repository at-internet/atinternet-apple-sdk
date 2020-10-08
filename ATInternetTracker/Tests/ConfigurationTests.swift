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
//  ConfigurationTests.swift
//  Tracker
//

import UIKit
import XCTest

class ConfigurationTests: XCTestCase {
    
    // Configuration définie
    let myConf = ["log":"customlog", "logSSL":"customlogs", "domain":"customdomain", "pixelPath":"custompixelpath","site":"customsite", "secure":"customsecure", "identifier":"customidentifier", "plugins":"", "enableBackgroundTask":"false", "storage":"never", "hashUserId":"false", "persistIdentifiedVisitor":"true","sessionBackgroundDuration":"60", "campaignLastPersistence": "true", "campaignLifetime": "30","downloadSource":"ext", "sendOnApplicationState":"all", "ignoreLimitedAdTracking":"false","sendHitWhenOptOut":"true", "maxHitSize": "4000", "UUIDDuration": "34", "UUIDExpirationMode": "relative", "proxyType": "http", "proxyAddress":"127.0.0.1:8888"]
    // Configuration par défaut
    let defaultConf = ["log":"", "logSSL":"", "domain":"xiti.com", "pixelPath":"/hit.xiti", "site":"", "identifier":"uuid", "plugins":"", "enableBackgroundTask":"false", "storage":"never", "hashUserId":"false", "persistIdentifiedVisitor":"true","sessionBackgroundDuration":"60", "campaignLastPersistence": "true", "campaignLifetime": "30","downloadSource":"ext", "sendOnApplicationState":"all", "ignoreLimitedAdTracking":"false","sendHitWhenOptOut":"true", "maxHitSize": "8000", "UUIDDuration": "397", "UUIDExpirationMode": "fixed", "proxyType": "none", "proxyAddress":""]
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    // On vérifie que qu'il est possible d'instancier plusieurs fois Configuration
    func testMultiInstance() {
        let config1 = Configuration()
        let config2 = Configuration()
        XCTAssert(config1 !== config2, "config1 et config2 ne doivent pas pointer vers la même référence")
    }
    
    // On vérifie l'initialisation avec la configuration par défaut
    func testDefaultConfigurationGetter() {
        var testOK = true;
        let config = Configuration().parameters
        
        for (key,value) in config {
            if (defaultConf[key] != value) {
                print("\(key) : -> \(String(describing: defaultConf[key])) !== ->\(value)")
                testOK = false;
                break;
            }
        }
        
        if (testOK) {
            if (defaultConf.count != config.count) {
                print("count failure")
                testOK = false;
            }
        }
        
        XCTAssert(testOK, "la configuration retournée doit être identique à la configuration par défaut")
    }
    
    // On vérifie l'initialisation avec la configuration définie
    func testCustomConfigurationGetter() {
        var testOK = true;
        let config = Configuration(customConfiguration: myConf).parameters
        
        for (key,value) in config {
            if (myConf[key] != value) {
                testOK = false;
            }
        }
        
        if (testOK) {
            if (myConf.count != config.count) {
                testOK = false;
            }
        }
        
        XCTAssert(testOK, "la configuration retournée doit être identique à la configuration définie")
    }
}
