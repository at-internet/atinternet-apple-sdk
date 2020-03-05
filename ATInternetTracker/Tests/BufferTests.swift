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
//  BufferTests.swift
//  Tracker
//

import UIKit
import XCTest
@testable import ATInternetTracker

class BufferTests: XCTestCase {
    
    // On instancie deux objets de type Parameter
    let paramPer = Param(key:"model", value:{"[apple]-[ipad4,4]"})
    let paramVol = Param(key:"p", value: {"home"})
    
    // On instancie deux tableaux contenant des objets de type Parameter
    let arrayPer = [Param(key:"key0p", value: {"value0p"}), Param(key:"key1p", value: {"value1p"})]
    let arrayVol = [Param(key:"key0v", value: {"value0v"}), Param(key:"key1v", value: {"value1v"})]
    
    // Instance de buffer utilisée pour les tests
    let buffer = Buffer(tracker: Tracker(configuration: ["log":"logp", "logSSL":"logs", "domain":"xiti.com", "pixelPath":"/hit.xiti", "site":"549808", "secure":"false", "identifier":"uuid", "sessionBackgroundDuration":"60" ]))

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    // On vérifie qu'il est possible d'ajouter un paramètre persistant dans le buffer
    func testAddParamPer() {
        buffer.persistentParameters[paramPer.key] = paramPer
        #if os(iOS)
        XCTAssertEqual(buffer.persistentParameters.count, 16, "persistentParameters doit contenir un élément")
        #elseif os(tvOS)
         XCTAssertEqual(buffer.persistentParameters.count, 15, "persistentParameters doit contenir un élément")
        #endif
    }
    
    // On vérifie qu'il est possible d'ajouter un paramètre volatile dans le buffer
    func testAddParamVol() {
        buffer.volatileParameters[paramVol.key] = paramVol
        XCTAssertEqual(buffer.volatileParameters.count, 1, "volatileParameters doit contenir un élément")
    }
    
    // On vérifie qu'il est possible de récupérer un paramètre persistant depuis le buffer
    func testGetParamPer() {
        buffer.persistentParameters[paramPer.key] = paramPer
        XCTAssert(paramPer.values[0]() == buffer.persistentParameters[paramPer.key]?.values[0](), "param et paramPer doivent avoir la même valeur pour key et value")
    }

    // On vérifie qu'il est possible d'instancier plusieurs fois Buffer
    func testMultiInstance() {
        let buffer1 = Buffer(tracker: Tracker(configuration: ["log":"logp", "logSSL":"logs", "domain":"xiti.com", "pixelPath":"/hit.xiti", "site":"549808", "secure":"false", "identifier":"uuid"]))
        let buffer2 = Buffer(tracker: Tracker(configuration: ["log":"logp", "logSSL":"logs", "domain":"xiti.com", "pixelPath":"/hit.xiti", "site":"549808", "secure":"false", "identifier":"uuid"]))
        XCTAssert(buffer1 !== buffer2, "buffer1 et buffer2 ne doivent pas pointer vers la même référence")
    }


}
