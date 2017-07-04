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
//  BuilderTests.swift
//  Tracker
//

import UIKit
import XCTest

class BuilderTests: XCTestCase, TrackerDelegate {
    
    func trackerNeedsFirstLaunchApproval(_ message: String) {
        print(message)
    }
    
    func buildDidEnd(_ status: HitStatus, message: String) {
        print(message)
    }
    
    func sendDidEnd(_ status: HitStatus, message: String) {
        print(message)
    }
    
    func saveDidEnd(_ message: String) {

    }
    
    func didCallPartner(_ response: String) {
        print(response)
    }
    
    func warningDidOccur(_ message: String) {
        print(message)
    }
    
    func errorDidOccur(_ message: String) {
        print(message)
    }
    
    var tracker = Tracker()
    let configuration = ["log":"logp", "logSSL":"logs", "domain":"xiti.com", "pixelPath":"/hit.xiti", "site":"549808", "secure":"false", "identifier":"uuid"]
    
    override func setUp() {
        super.setUp()
        tracker = Tracker(configuration: configuration)
        tracker.delegate = self
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func getDate() -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
    
    // Teste que le hit construit avec une paramètre dont la valeur est une closure contient bien le résultat attendu
    func testBuildHitWithClosureParam() {
        
        let today = getDate()
        
        let pageParam = Param(key: "p", value: {"home"})
        let hlParam = Param(key: "date", value: {self.getDate()})
        
        tracker.buffer.volatileParameters["p"] = pageParam
        tracker.buffer.volatileParameters["date"] = hlParam
        
        let builder = Builder(tracker: self.tracker)
        
        let hits = builder.build()
        let url = URL(string: hits[0])
        let urlComponents = url?.query!.components(separatedBy: "&")
        
        for component in urlComponents! as [String] {
            let pairComponents = component.components(separatedBy: "=")
            
            if(pairComponents[0] == "p") {
                XCTAssert(pairComponents[1] == "home", "le paramètre p doit être égal à home")
            } else if(pairComponents[0] == "date"){
                XCTAssert(pairComponents[1] == today, "le paramètre date doit être égal à getDate()")
            }
        }
    }
    
    // Teste que le hit construit avec une paramètre dont la valeur est un float contient bien le résultat attendu
    func testBuildHitWithFloatParam() {
        
        let floatParam = Param(key: "float", value: {Tool.convertToString(3.1415).value})

        tracker.buffer.volatileParameters["float"] = floatParam
        
        let builder = Builder(tracker: self.tracker)
        
        let hits = builder.build()
        let url = URL(string: hits[0])
        
        let urlComponents = url?.query!.components(separatedBy: "&")
        
        for component in urlComponents! as [String] {
            let pairComponents = component.components(separatedBy: "=")
            
            if(pairComponents[0] == "float"){
                XCTAssert(pairComponents[1] == "3.1415", "le paramètre float doit être égal à 3.1415")
                
                break
            }
        }
    }
    
    // Teste que le hit construit avec une paramètre dont la valeur est un int contient bien le résultat attendu
    func testBuildHitWithIntParam() {
        
        let intParam = Param(key: "int", value: {Tool.convertToString(3).value})
        
        tracker.buffer.volatileParameters["int"] = intParam
        
        let builder = Builder(tracker: self.tracker)
        
        let hits = builder.build()
        let url = URL(string: hits[0])
        

        let urlComponents = url?.query!.components(separatedBy: "&")
        
        for component in urlComponents! as [String] {
            let pairComponents = component.components(separatedBy: "=")
            
            if(pairComponents[0] == "int"){
                XCTAssert(pairComponents[1] == "3".percentEncodedString, "le paramètre int doit être égal à 3")
                
                break
            }
        }
    }
    
    // Teste que le hit construit avec une paramètre dont la valeur est un bool contient bien le résultat attendu
    func testBuildHitWithBoolParam() {

        let trueBoolParam = Param(key: "trueBool", value: {Tool.convertToString(true).value})
        let falseBoolParam = Param(key: "falseBool", value: {Tool.convertToString(false).value})
        
        tracker.buffer.volatileParameters["trueBool"] = trueBoolParam
        tracker.buffer.volatileParameters["falseBool"] = falseBoolParam
        
        let builder = Builder(tracker: self.tracker)
        
        let hits = builder.build()
        let url = URL(string: hits[0])
        

        let urlComponents = url?.query!.components(separatedBy: "&")
        
        for component in urlComponents! as [String] {
            let pairComponents = component.components(separatedBy: "=")
            
            if(pairComponents[0] == "trueBool"){
                XCTAssert(pairComponents[1] == "true".percentEncodedString, "le paramètre trueBool doit être égal à true")
                
                break
            }
            
            if(pairComponents[1] == "falseBool"){
                XCTAssert(pairComponents[1] == "false".percentEncodedString, "le paramètre falseBool doit être égal à false")
                
                break
            }
        }
    }
    
    // Teste que le hit construit avec une paramètre dont la valeur est un dictionnaire contient bien le résultat attendu
    func testBuildHitWithDictionnaryParam() {
        
        let dictParam = Param(key: "json", value: {Tool.convertToString(["légume":["chou","patate","tomate","carotte"], "fruits": ["pomme", "abricot", "poire"]]).value})

        tracker.buffer.volatileParameters["json"] = dictParam
        
        let builder = Builder(tracker: self.tracker)
        
        let hits = builder.build()
        
        let urlComponentsTmp = hits[0].components(separatedBy: "?")[1]
        let urlComponents = urlComponentsTmp.components(separatedBy: "&")
        
        for component in urlComponents as [String] {
            let pairComponents = component.components(separatedBy: "=")
            
            if(pairComponents[0] == "json"){
                XCTAssert(pairComponents[1] == dictParam.values[0](), "le paramètre json doit être égal à {\"fruits\":[\"pomme\",\"abricot\",\"poire\"],\"légume\":[\"chou\",\"patate\",\"tomate\",\"carotte\"]}")
                
                break
            }
        }
    }
    
    // Teste que le hit construit avec une paramètre dont la valeur est un tableau contient bien le résultat attendu
    func testBuildHitWithArrayParam() {
        
        let arrayParam = Param(key: "array", value: {Tool.convertToString(["chou","patate","tomate","carotte"]).value})
        
        tracker.buffer.volatileParameters["array"] = arrayParam
        
        let builder = Builder(tracker: self.tracker)
        
        let hits = builder.build()
        let url = URL(string: hits[0])
        
        let urlComponents = url?.query!.components(separatedBy: "&")
        
        for component in urlComponents! as [String] {
            let pairComponents = component.components(separatedBy: "=")
            
            if(pairComponents[0] == "array"){
                XCTAssert(pairComponents[1] == arrayParam.values[0](), "le paramètre json doit être égal à chou,patate,tomate,carotte")
                
                break
            }
        }
    }

    // Teste que le hit construit avec une paramètre dont la valeur est un tableau et le separator |contient bien le résultat attendu
    func testBuildHitWithArrayParamAndPipeSeparator() {
        
        let arrayOption = ParamOption()
        arrayOption.separator = "|"
        
        let arrayParam = Param(key: "array", value: {Tool.convertToString(["chou","patate","tomate","carotte"]).value}, options:arrayOption)
        
        tracker.buffer.volatileParameters["array"] = arrayParam
        
        let builder = Builder(tracker: self.tracker)
        
        let hits = builder.build()
        let url = URL(string: hits[0])
        
        let urlComponents = url?.query!.components(separatedBy: "&")
        
        for component in urlComponents! as [String] {
            let pairComponents = component.components(separatedBy: "=")
            
            if(pairComponents[0] == "array"){
                XCTAssert(pairComponents[1] == arrayParam.values[0](), "le paramètre json doit être égal à chou|patate|tomate|carotte")
                
                break
            }
        }
    }
    
    // Teste l'envoi d'un hit
    func testSendHit() {        
        let pageParam = Param(key: "p", value: {"home"})
        
        let stcParamOption = ParamOption()
        stcParamOption.encode = true
        
        let stcParam = Param(key: "stc", value: {Tool.convertToString(["légume":["chou","patate","tomate","carotte"], "fruits": ["pomme", "abricot", "poire"]]).value}, options: stcParamOption)
        let arrayParam = Param(key: "array", value: {Tool.convertToString(["chou", "choux-fleur"]).value}, options: stcParamOption)
        
        let refParamOptions = ParamOption()
        refParamOptions.relativePosition = ParamOption.RelativePosition.last
        
        let refParam = Param(key: "ref", value: {"www.atinternet.com"}, options: refParamOptions)
        let dsluParam = Param(key:"dslu", value: {Tool.convertToString(10).value})
        
        let crashParamOptions = ParamOption()
        crashParamOptions.relativePosition = ParamOption.RelativePosition.after
        crashParamOptions.relativeParameterKey = "stc"
        
        let crashParam = Param(key: "crash", value: {Tool.convertToString(false).value}, options: crashParamOptions)
        
        tracker.buffer.volatileParameters[pageParam.key] = pageParam
        tracker.buffer.volatileParameters[stcParam.key] = stcParam
        tracker.buffer.volatileParameters[refParam.key] = refParam
        tracker.buffer.volatileParameters[dsluParam.key] = dsluParam
        tracker.buffer.volatileParameters[crashParam.key] = crashParam
        tracker.buffer.volatileParameters[arrayParam.key] = arrayParam
        
        let builder = Builder(tracker: self.tracker)
        
        let expectation = self.expectation(description: "Hit sent")
        
        let hits = builder.build()
        let hit = Hit(url: hits[0])
        let sender = Sender(tracker: tracker, hit: hit, forceSendOfflineHits: false, mhOlt: nil)
        
       
        sender.sendWithCompletionHandler({(success) in
            XCTAssert(success, "Hit could not be sent")
            expectation.fulfill()
        })
        
        self.waitForExpectations(timeout: 5.0, handler: nil)
    }
    
    // Teste que la méthode makeSubQuery formatte correctement les paramètres sous la forme &p=v
    func testMakeSubQuery() {
        let builder = Builder(tracker: self.tracker)
        let queryString = builder.makeSubQuery("p", value: "home")
        
        XCTAssert(queryString == "&p=home", "la querystring doit être égale à p=home")
    }
    
    // Teste le formattage de paramètres volatiles
    func testPreQueryWithVolatileParameters() {
        let pageParam = Param(key: "p", value: {"home"})
        let stcParam = Param(key: "stc", value: {Tool.convertToString(["chou", "patate", "carotte"]).value})
        
        let refParamOption = ParamOption()
        refParamOption.relativePosition = ParamOption.RelativePosition.last
        
        let refParam = Param(key: "ref", value: {"www.atinternet.com?test1=1&test2=2&test3=<script></script>"}, options: refParamOption)
        let dsluParam = Param(key:"dslu", value: {Tool.convertToString(10).value})
        let crashParam = Param(key:"crash", value: {Tool.convertToString(false).value})
        
        tracker.buffer.volatileParameters[pageParam.key] = pageParam
        tracker.buffer.volatileParameters[stcParam.key] = stcParam
        tracker.buffer.volatileParameters[refParam.key] = refParam
        tracker.buffer.volatileParameters[dsluParam.key] = dsluParam
        tracker.buffer.volatileParameters[crashParam.key] = crashParam
        
        let builder = Builder(tracker: self.tracker)
        
        var strings = builder.prepareQuery()
        
        XCTAssert(strings["p"]!.0 == "&p=home", "le premier paramètre doit être égal à &p=home")
        XCTAssert(strings["stc"]!.0 == "&stc=chou,patate,carotte", "le second paramètre doit être égal à &stc=chou,patate,carotte")
        XCTAssert(strings["dslu"]!.0 == "&dslu=10", "le paramètre dslu doit être égal à &dslu=10")
        XCTAssert(strings["crash"]!.0 == "&crash=false", "le paramètre crash doit être égal à &crash=false")
        XCTAssert(strings["ref"]!.0 == "&ref=www.atinternet.com?test1=1$test2=2$test3=script/script", "le paramètre ref doit être égal à &ref=www.atinternet.com et doit être le dernier paramètre")
    }
    
    // Teste le formattage de paramètres permanents
    func testPreQueryWithPersistentParameters() {
        let pageParam = Param(key: "p", value: {"home"})
        let stcParam = Param(key: "stc", value: {Tool.convertToString(["chou", "patate", "carotte"]).value})
        
        let refParamOption = ParamOption()
        refParamOption.relativePosition = ParamOption.RelativePosition.last
        
        let refParam = Param(key: "ref", value: {"www.atinternet.com?test1=1&test2=2&test3=<script></script>"}, options: refParamOption)
        let dsluParam = Param(key:"dslu", value: {Tool.convertToString(10).value})
        let crashParam = Param(key:"crash", value: {Tool.convertToString(false).value})
        
        tracker.buffer.persistentParameters[pageParam.key] = pageParam
        tracker.buffer.persistentParameters[stcParam.key] = stcParam
        tracker.buffer.persistentParameters[refParam.key] = refParam
        tracker.buffer.persistentParameters[dsluParam.key] = dsluParam
        tracker.buffer.persistentParameters[crashParam.key] = crashParam
        
        let builder = Builder(tracker: self.tracker)
        
        var strings = builder.prepareQuery()
        
        XCTAssert(strings["p"]?.0 == "&p=home", "le premier paramètre doit être égal à &p=home")
        XCTAssert(strings["stc"]?.0 == "&stc=chou,patate,carotte", "le second paramètre doit être égal à &stc=chou,patate,carotte")
        XCTAssert(strings["dslu"]?.0 == "&dslu=10", "le paramètre dslu doit être égal à &dslu=10")
        XCTAssert(strings["crash"]?.0 == "&crash=false", "le paramètre crash doit être égal à &crash=false")
        XCTAssert(strings["ref"]?.0 == "&ref=www.atinternet.com?test1=1$test2=2$test3=script/script", "le paramètre ref doit être égal à &ref=www.atinternet.com et doit être le dernier paramètre")
    }
    
    // Teste le formattage de paramètres volatiles et persistents
    func testPreQueryWithPersistentAndVolatileParameters() {
        let pageParam = Param(key: "p", value: {"home"})
        let stcParam = Param(key: "stc", value: {Tool.convertToString(["chou", "patate", "carotte"]).value})
        
        let refParamOption = ParamOption()
        refParamOption.relativePosition = ParamOption.RelativePosition.last
        
        let refParam = Param(key: "ref", value: {"www.atinternet.com?test1=1&test2=2&test3=<script></script>"}, options: refParamOption)
        let dsluParam = Param(key:"dslu", value: {Tool.convertToString(10).value})
        let crashParam = Param(key:"crash", value: {Tool.convertToString(false).value})
        
        tracker.buffer.persistentParameters[pageParam.key] = pageParam
        tracker.buffer.persistentParameters[stcParam.key] = stcParam
        tracker.buffer.persistentParameters[refParam.key] = refParam
        tracker.buffer.volatileParameters[dsluParam.key] = dsluParam
        tracker.buffer.volatileParameters[crashParam.key] = crashParam
        
        let builder = Builder(tracker: self.tracker)
        
        var strings = builder.prepareQuery()
        
        XCTAssert(strings["p"]!.0 == "&p=home", "le premier paramètre doit être égal à &p=home")
        XCTAssert(strings["stc"]!.0 == "&stc=chou,patate,carotte", "le second paramètre doit être égal à &stc=chou,patate,carotte")
        XCTAssert(strings["dslu"]!.0 == "&dslu=10", "le paramètre dslu doit être égal à &dslu=10")
        XCTAssert(strings["crash"]!.0 == "&crash=false", "le paramètre crash doit être égal à &crash=false")
        XCTAssert(strings["ref"]?.0 == "&ref=www.atinternet.com?test1=1$test2=2$test3=script/script", "le paramètre ref doit être égal à &ref=www.atinternet.com et doit être le dernier paramètre")
    }
    
    func testOrganizeParameters() {
        let pageParamOptions = ParamOption()
        pageParamOptions.relativePosition = ParamOption.RelativePosition.first
        let pageParam = Param(key: "p", value: {"home"}, options: pageParamOptions)
        
        let stcParam = Param(key: "stc", value: {Tool.convertToString(["légume":["chou","patate","tomate","carotte"], "fruits": ["pomme", "abricot", "poire"]]).value})
        let arrayParam = Param(key: "array", value: {Tool.convertToString(["chou", "choux-fleur"]).value})
        
        
        let refParam = Param(key: "ref", value: {"www.atinternet.com"})
        let dsluParam = Param(key:"dslu", value: {Tool.convertToString(10).value})
        
        let crashParamOptions = ParamOption()
        crashParamOptions.relativePosition = ParamOption.RelativePosition.last
        
        let crashParam = Param(key:"crash", value: {Tool.convertToString(false).value}, options: crashParamOptions)
        
        let hlParamOptions = ParamOption()
        hlParamOptions.persistent = true
        let hlParam = Param(key: "hl", value: {self.getDate()}, options: hlParamOptions)
        
        tracker.buffer.volatileParameters[pageParam.key] = pageParam
        tracker.buffer.volatileParameters[stcParam.key] = stcParam
        tracker.buffer.volatileParameters[refParam.key] = refParam
        tracker.buffer.volatileParameters[dsluParam.key] = dsluParam
        tracker.buffer.volatileParameters[crashParam.key] = crashParam
        tracker.buffer.persistentParameters[hlParam.key] = hlParam
        tracker.buffer.volatileParameters[arrayParam.key] = arrayParam
        
        let builder = Builder(tracker: self.tracker)
        
        var buffer = [String:Param]()
        builder.persistentParameters.forEach { (k,v) in buffer[k] = v }
        builder.volatileParameters.forEach { (k,v) in buffer[k] = v }
        var params = builder.organizeParameters(buffer)
        
        XCTAssert(params[0].key == "p", "Le premier paramètre doit etre p=")
        #if os(iOS)
        XCTAssert(params[params.count-2].key == "crash", "Le sixième paramètre doit etre hl=")
        XCTAssert(params[params.count-1].key == "ref", "Le septième paramètre doit etre ref=")
        #elseif os(tvOS)
        XCTAssert(params[params.count-2].key == "stc", "Le sixième paramètre doit etre hl=")
        XCTAssert(params[params.count-1].key == "ref", "Le septième paramètre doit etre ref=")
        #endif
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure() {
            // Put the code you want to measure the time of here.
        }
    }
    
    
    /* Tests de la gestion du multihits */
    
    func testMultihitsSplitOnParameterWithoutError() {
        for i in 1...60 {
            let param = Param(key:"bigparameter\(i)", value: {Tool.convertToString("bigvalue\(i)").value})
            tracker.buffer.volatileParameters[param.key] = param
        }
        
        let builder = Builder(tracker: self.tracker)
        let hits = builder.build()
        
        var isErr = false
        for hit in hits {
            let rangeErr = hit.range(of: "mherr=1")
            if let _ = rangeErr {
                isErr = true
                break
            }
        }
        
        XCTAssertTrue(hits.count > 1, "Le hit est trop long et devrait être découpé en plusieurs morceaux")
        XCTAssertFalse(isErr, "Un morceau de hit contient la variable d'erreur alors qu'il ne devrait pas")
    }
    
    func testMultihitsSplitOnValueWithoutError() {
        var array = [String]()
        
        for i in 1...150 {
            array.append("abigtestvalue\(i)")
        }
        
        let param = Param(key:"ati", value: {Tool.convertToString(array).value})
        tracker.buffer.volatileParameters[param.key] = param
        let builder = Builder(tracker: self.tracker)
        let hits = builder.build()
        
        var isErr = false
        for hit in hits {
            let rangeErr = hit.range(of:"mherr=1")
            if let _ = rangeErr {
                isErr = true
                break
            }
        }
        
        XCTAssertTrue(hits.count > 1, "Le hit est trop long et devrait être découpé en plusieurs morceaux")
        XCTAssertFalse(isErr, "Un morceau de hit contient la variable d'erreur alors qu'il ne devrait pas")
    }
    
    func testMultihitsSplitOnValueWithError() {
        var json = [String: String]()
        
        var val = "themegavalue30"
        for i in 1...60 {
            json["key\(i)"] = "value\(i)"
            if i == 30 {
                for _ in 1...10 {
                    val += val + "themegavalue30"
                }
            }
        }
        json["key30"] = val
        
        let param = Param(key:"ati", value: {Tool.convertToString(json).value})
        tracker.buffer.volatileParameters[param.key] = param
        let builder = Builder(tracker: self.tracker)
        let hits = builder.build()
        
        var isErr = false
        for hit in hits {
            let rangeErr = hit.range(of: "mherr=1")
            if let _ = rangeErr {
                isErr = true
                break
            }
        }
        
        XCTAssertTrue(hits.count > 1, "Le hit est trop long et devrait être découpé en plusieurs morceaux")
        XCTAssertTrue(isErr, "Aucun morceau de hit ne contient la variable d'erreur alors que cela devrait être le cas")
    }
    
    func testMultihitsSplitOnValueWithNotAllowedParam() {
        var array = [String]()
        
        for i in 1...150 {
            array.append("abigtestvalue\(i)")
        }
        
        let param = Param(key:"var", value: {Tool.convertToString(array).value})
        tracker.buffer.volatileParameters[param.key] = param
        let builder = Builder(tracker: self.tracker)
        let hits = builder.build()
        
        var isErr = false
        for hit in hits {
            let rangeErr = hit.range(of: "mherr=1")
            if let _ = rangeErr {
                isErr = true
                break
            }
        }
        
        XCTAssertTrue(hits.count == 1, "Le hit ne devrait pas être découpé")
        XCTAssertTrue(isErr, "Le hit ne contient pas la variable d'erreur alors que cela devrait être le cas")
    }

}
