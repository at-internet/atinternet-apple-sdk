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
        
        let pageParam = Param(key: "p", value: {"home"}, type: .string)
        let hlParam = Param(key: "date", value: {self.getDate()}, type: .string)
        
        tracker.buffer.volatileParameters.append(pageParam)
        tracker.buffer.volatileParameters.append(hlParam)
        
        let builder = Builder(tracker: self.tracker, volatileParameters: tracker.buffer.volatileParameters, persistentParameters: tracker.buffer.persistentParameters)
        
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
        
        let floatParam = Param(key: "float", value: {Tool.convertToString(3.1415).value}, type: .float)

        tracker.buffer.volatileParameters.append(floatParam)
        
        let builder = Builder(tracker: self.tracker, volatileParameters: tracker.buffer.volatileParameters, persistentParameters: tracker.buffer.persistentParameters)
        
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
        
        let intParam = Param(key: "int", value: {Tool.convertToString(3).value}, type: .integer)
        
        tracker.buffer.volatileParameters.append(intParam)
        
        let builder = Builder(tracker: self.tracker, volatileParameters: tracker.buffer.volatileParameters, persistentParameters: tracker.buffer.persistentParameters)
        
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

        let trueBoolParam = Param(key: "trueBool", value: {Tool.convertToString(true).value}, type: .bool)
        let falseBoolParam = Param(key: "falseBool", value: {Tool.convertToString(false).value}, type: .bool)
        
        tracker.buffer.volatileParameters.append(trueBoolParam)
        tracker.buffer.volatileParameters.append(falseBoolParam)
        
        let builder = Builder(tracker: self.tracker, volatileParameters: tracker.buffer.volatileParameters, persistentParameters: tracker.buffer.persistentParameters)
        
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
        
        let dictParam = Param(key: "json", value: {Tool.convertToString(["légume":["chou","patate","tomate","carotte"], "fruits": ["pomme", "abricot", "poire"]]).value}, type: .json)

        tracker.buffer.volatileParameters.append(dictParam)
        
        let builder = Builder(tracker: self.tracker, volatileParameters: tracker.buffer.volatileParameters, persistentParameters: tracker.buffer.persistentParameters)
        
        let hits = builder.build()
        
        let urlComponentsTmp = hits[0].components(separatedBy: "?")[1]
        let urlComponents = urlComponentsTmp.components(separatedBy: "&")
        
        for component in urlComponents as [String] {
            let pairComponents = component.components(separatedBy: "=")
            
            if(pairComponents[0] == "json"){
                XCTAssert(pairComponents[1] == dictParam.value(), "le paramètre json doit être égal à {\"fruits\":[\"pomme\",\"abricot\",\"poire\"],\"légume\":[\"chou\",\"patate\",\"tomate\",\"carotte\"]}")
                
                break
            }
        }
    }
    
    // Teste que le hit construit avec une paramètre dont la valeur est un tableau contient bien le résultat attendu
    func testBuildHitWithArrayParam() {
        
        let arrayParam = Param(key: "array", value: {Tool.convertToString(["chou","patate","tomate","carotte"]).value}, type: .string)
        
        tracker.buffer.volatileParameters.append(arrayParam)
        
        let builder = Builder(tracker: self.tracker, volatileParameters: tracker.buffer.volatileParameters, persistentParameters: tracker.buffer.persistentParameters)
        
        let hits = builder.build()
        let url = URL(string: hits[0])
        
        let urlComponents = url?.query!.components(separatedBy: "&")
        
        for component in urlComponents! as [String] {
            let pairComponents = component.components(separatedBy: "=")
            
            if(pairComponents[0] == "array"){
                XCTAssert(pairComponents[1] == arrayParam.value(), "le paramètre json doit être égal à chou,patate,tomate,carotte")
                
                break
            }
        }
    }

    // Teste que le hit construit avec une paramètre dont la valeur est un tableau et le separator |contient bien le résultat attendu
    func testBuildHitWithArrayParamAndPipeSeparator() {
        
        let arrayOption = ParamOption()
        arrayOption.separator = "|"
        
        let arrayParam = Param(key: "array", value: {Tool.convertToString(["chou","patate","tomate","carotte"]).value}, type: .string, options:arrayOption)
        
        tracker.buffer.volatileParameters.append(arrayParam)
        
        let builder = Builder(tracker: self.tracker, volatileParameters: tracker.buffer.volatileParameters, persistentParameters: tracker.buffer.persistentParameters)
        
        let hits = builder.build()
        let url = URL(string: hits[0])
        
        let urlComponents = url?.query!.components(separatedBy: "&")
        
        for component in urlComponents! as [String] {
            let pairComponents = component.components(separatedBy: "=")
            
            if(pairComponents[0] == "array"){
                XCTAssert(pairComponents[1] == arrayParam.value(), "le paramètre json doit être égal à chou|patate|tomate|carotte")
                
                break
            }
        }
    }
    
    // Teste l'envoi d'un hit
    func testSendHit() {        
        let pageParam = Param(key: "p", value: {"home"}, type: .string)
        
        let stcParamOption = ParamOption()
        stcParamOption.encode = true
        
        let stcParam = Param(key: "stc", value: {Tool.convertToString(["légume":["chou","patate","tomate","carotte"], "fruits": ["pomme", "abricot", "poire"]]).value}, type: .json, options: stcParamOption)
        let arrayParam = Param(key: "array", value: {Tool.convertToString(["chou", "choux-fleur"]).value}, type: .string, options: stcParamOption)
        
        let refParamOptions = ParamOption()
        refParamOptions.relativePosition = ParamOption.RelativePosition.last
        
        let refParam = Param(key: "ref", value: {"www.atinternet.com"}, type: .string, options: refParamOptions)
        let dsluParam = Param(key:"dslu", value: {Tool.convertToString(10).value}, type: .integer)
        
        let crashParamOptions = ParamOption()
        crashParamOptions.relativePosition = ParamOption.RelativePosition.after
        crashParamOptions.relativeParameterKey = "stc"
        
        let crashParam = Param(key: "crash", value: {Tool.convertToString(false).value}, type: .bool, options: crashParamOptions)
        
        tracker.buffer.volatileParameters.append(pageParam)
        tracker.buffer.volatileParameters.append(stcParam)
        tracker.buffer.volatileParameters.append(refParam)
        tracker.buffer.volatileParameters.append(dsluParam)
        tracker.buffer.volatileParameters.append(crashParam)
        tracker.buffer.volatileParameters.append(arrayParam)
        
        let builder = Builder(tracker: self.tracker, volatileParameters: tracker.buffer.volatileParameters, persistentParameters: tracker.buffer.persistentParameters)
        
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

    // Teste que la méthode findParameterPosition retourne la bonne position du paramètre dans la collection
    func testFindParameterPosition() {
        var parameters = [Param]()
        let pageParam = Param(key: "p", value: {"home"}, type: .string)
        let stcParam = Param(key: "stc", value: {Tool.convertToString(["chou", "patate", "carotte"]).value}, type: .string)
        let refParamOptions = ParamOption()
        refParamOptions.relativePosition = ParamOption.RelativePosition.last
        
        let refParam = Param(key: "ref", value: {"www.atinternet.com"}, type: .string, options: refParamOptions)
        let dsluParam = Param(key:"dslu", value: {Tool.convertToString(10).value}, type: .integer)
        let crashParamOptions = ParamOption()
        crashParamOptions.relativePosition = ParamOption.RelativePosition.after
        crashParamOptions.relativeParameterKey = "stc"
        
        let crashParam = Param(key:"crash", value: {Tool.convertToString(false).value}, type: .bool, options: crashParamOptions)
        let hlParam = Param(key: "hl", value: {self.getDate()}, type: .string)
        
        parameters.append(pageParam)
        parameters.append(stcParam)
        parameters.append(refParam)
        parameters.append(dsluParam)
        parameters.append(crashParam)
        parameters.append(hlParam)
        
        let posPageParam = Tool.findParameterPosition("p", arrays: parameters).first!.index
        let posStcParam = Tool.findParameterPosition("stc", arrays: parameters).first!.index
        let posRefParam = Tool.findParameterPosition("ref", arrays: parameters).first!.index
        let posDsluParam = Tool.findParameterPosition("dslu", arrays: parameters).first!.index
        let posCrashParam = Tool.findParameterPosition("crash", arrays: parameters).first!.index
        let posHlParam = Tool.findParameterPosition("hl", arrays: parameters).first!.index
        
        XCTAssert(posPageParam == 0, "le paramètre p aurait du être en position 0")
        XCTAssert(posStcParam == 1, "le paramètre stc aurait du être en position 1")
        XCTAssert(posRefParam == 2, "le paramètre ref aurait du être en position 2")
        XCTAssert(posDsluParam == 3, "le paramètre dslu aurait du être en position 3")
        XCTAssert(posCrashParam == 4, "le paramètre crash aurait du être en position 4")
        XCTAssert(posHlParam == 5, "le paramètre hl aurait du être en position 5")
    }
    
    // Teste que la méthode makeSubQuery formatte correctement les paramètres sous la forme &p=v
    func testMakeSubQuery() {
        let builder = Builder(tracker: self.tracker, volatileParameters: tracker.buffer.volatileParameters, persistentParameters: tracker.buffer.persistentParameters)
        let queryString = builder.makeSubQuery("p", value: "home")
        
        XCTAssert(queryString == "&p=home", "la querystring doit être égale à p=home")
    }
    
    // Teste le formattage de paramètres volatiles
    func testPreQueryWithVolatileParameters() {
        let pageParam = Param(key: "p", value: {"home"}, type: .string)
        let stcParam = Param(key: "stc", value: {Tool.convertToString(["chou", "patate", "carotte"]).value}, type: .string)
        
        let refParamOption = ParamOption()
        refParamOption.relativePosition = ParamOption.RelativePosition.last
        
        let refParam = Param(key: "ref", value: {"www.atinternet.com?test1=1&test2=2&test3=<script></script>"}, type: .string, options: refParamOption)
        let dsluParam = Param(key:"dslu", value: {Tool.convertToString(10).value}, type: .integer)
        let crashParam = Param(key:"crash", value: {Tool.convertToString(false).value}, type: .bool)
        
        tracker.buffer.volatileParameters.append(pageParam)
        tracker.buffer.volatileParameters.append(stcParam)
        tracker.buffer.volatileParameters.append(refParam)
        tracker.buffer.volatileParameters.append(dsluParam)
        tracker.buffer.volatileParameters.append(crashParam)
        
        let builder = Builder(tracker: self.tracker, volatileParameters: tracker.buffer.volatileParameters, persistentParameters: tracker.buffer.persistentParameters)
        
        var strings = builder.prepareQuery()
        
        #if os(iOS)
        XCTAssert(strings[14].str == "&p=home", "le premier paramètre doit être égal à &p=home")
        XCTAssert(strings[15].str == "&stc=chou,patate,carotte", "le second paramètre doit être égal à &stc=chou,patate,carotte")
        XCTAssert(strings[16].str == "&dslu=10", "le paramètre dslu doit être égal à &dslu=10")
        XCTAssert(strings[17].str == "&crash=false", "le paramètre crash doit être égal à &crash=false")
        XCTAssert(strings[18].str == "&ref=www.atinternet.com?test1=1$test2=2$test3=script/script", "le paramètre ref doit être égal à &ref=www.atinternet.com et doit être le dernier paramètre")
        #elseif os(tvOS)
        XCTAssert(strings[13].str == "&p=home", "le premier paramètre doit être égal à &p=home")
        XCTAssert(strings[14].str == "&stc=chou,patate,carotte", "le second paramètre doit être égal à &stc=chou,patate,carotte")
        XCTAssert(strings[15].str == "&dslu=10", "le paramètre dslu doit être égal à &dslu=10")
        XCTAssert(strings[16].str == "&crash=false", "le paramètre crash doit être égal à &crash=false")
        XCTAssert(strings[17].str == "&ref=www.atinternet.com?test1=1$test2=2$test3=script/script", "le paramètre ref doit être égal à &ref=www.atinternet.com et doit être le dernier paramètre")
        #endif
    }
    
    // Teste le formattage de paramètres permanents
    func testPreQueryWithPersistentParameters() {
        let pageParam = Param(key: "p", value: {"home"}, type: .string)
        let stcParam = Param(key: "stc", value: {Tool.convertToString(["chou", "patate", "carotte"]).value}, type: .string)
        
        let refParamOption = ParamOption()
        refParamOption.relativePosition = ParamOption.RelativePosition.last
        
        let refParam = Param(key: "ref", value: {"www.atinternet.com?test1=1&test2=2&test3=<script></script>"}, type: .string, options: refParamOption)
        let dsluParam = Param(key:"dslu", value: {Tool.convertToString(10).value}, type: .integer)
        let crashParam = Param(key:"crash", value: {Tool.convertToString(false).value}, type: .bool)
        
        tracker.buffer.persistentParameters.append(pageParam)
        tracker.buffer.persistentParameters.append(stcParam)
        tracker.buffer.persistentParameters.append(refParam)
        tracker.buffer.persistentParameters.append(dsluParam)
        tracker.buffer.persistentParameters.append(crashParam)
        
        let builder = Builder(tracker: self.tracker, volatileParameters: tracker.buffer.volatileParameters, persistentParameters: tracker.buffer.persistentParameters)
        
        var strings = builder.prepareQuery()
        
        #if os(iOS)
        XCTAssert(strings[14].str == "&p=home", "le premier paramètre doit être égal à &p=home")
        XCTAssert(strings[15].str == "&stc=chou,patate,carotte", "le second paramètre doit être égal à &stc=chou,patate,carotte")
        XCTAssert(strings[16].str == "&dslu=10", "le paramètre dslu doit être égal à &dslu=10")
        XCTAssert(strings[17].str == "&crash=false", "le paramètre crash doit être égal à &crash=false")
        XCTAssert(strings[18].str == "&ref=www.atinternet.com?test1=1$test2=2$test3=script/script", "le paramètre ref doit être égal à &ref=www.atinternet.com et doit être le dernier paramètre")
        #elseif os(tvOS)
        XCTAssert(strings[13].str == "&p=home", "le premier paramètre doit être égal à &p=home")
        XCTAssert(strings[14].str == "&stc=chou,patate,carotte", "le second paramètre doit être égal à &stc=chou,patate,carotte")
        XCTAssert(strings[15].str == "&dslu=10", "le paramètre dslu doit être égal à &dslu=10")
        XCTAssert(strings[16].str == "&crash=false", "le paramètre crash doit être égal à &crash=false")
        XCTAssert(strings[17].str == "&ref=www.atinternet.com?test1=1$test2=2$test3=script/script", "le paramètre ref doit être égal à &ref=www.atinternet.com et doit être le dernier paramètre")
        #endif
    }
    
    // Teste le formattage de paramètres volatiles et persistents
    func testPreQueryWithPersistentAndVolatileParameters() {
        let pageParam = Param(key: "p", value: {"home"}, type: .string)
        let stcParam = Param(key: "stc", value: {Tool.convertToString(["chou", "patate", "carotte"]).value}, type: .string)
        
        let refParamOption = ParamOption()
        refParamOption.relativePosition = ParamOption.RelativePosition.last
        
        let refParam = Param(key: "ref", value: {"www.atinternet.com?test1=1&test2=2&test3=<script></script>"}, type: .string, options: refParamOption)
        let dsluParam = Param(key:"dslu", value: {Tool.convertToString(10).value}, type: .integer)
        let crashParam = Param(key:"crash", value: {Tool.convertToString(false).value}, type: .bool)
        
        tracker.buffer.persistentParameters.append(pageParam)
        tracker.buffer.persistentParameters.append(stcParam)
        tracker.buffer.persistentParameters.append(refParam)
        tracker.buffer.volatileParameters.append(dsluParam)
        tracker.buffer.volatileParameters.append(crashParam)
        
        let builder = Builder(tracker: self.tracker, volatileParameters: tracker.buffer.volatileParameters, persistentParameters: tracker.buffer.persistentParameters)
        
        var strings = builder.prepareQuery()
        
        #if os(iOS)
        XCTAssert(strings[14].str == "&p=home", "le premier paramètre doit être égal à &p=home")
        XCTAssert(strings[15].str == "&stc=chou,patate,carotte", "le second paramètre doit être égal à &stc=chou,patate,carotte")
        XCTAssert(strings[16].str == "&dslu=10", "le paramètre dslu doit être égal à &dslu=10")
        XCTAssert(strings[17].str == "&crash=false", "le paramètre crash doit être égal à &crash=false")
        XCTAssert(strings[18].str == "&ref=www.atinternet.com?test1=1$test2=2$test3=script/script", "le paramètre ref doit être égal à &ref=www.atinternet.com et doit être le dernier paramètre")
        #elseif os(tvOS)
        XCTAssert(strings[13].str == "&p=home", "le premier paramètre doit être égal à &p=home")
        XCTAssert(strings[14].str == "&stc=chou,patate,carotte", "le second paramètre doit être égal à &stc=chou,patate,carotte")
        XCTAssert(strings[15].str == "&dslu=10", "le paramètre dslu doit être égal à &dslu=10")
        XCTAssert(strings[16].str == "&crash=false", "le paramètre crash doit être égal à &crash=false")
        XCTAssert(strings[17].str == "&ref=www.atinternet.com?test1=1$test2=2$test3=script/script", "le paramètre ref doit être égal à &ref=www.atinternet.com et doit être le dernier paramètre")
        #endif
    }
    
    func testOrganizeParameters() {
        let pageParam = Param(key: "p", value: {"home"}, type: .string)
        
        let stcParam = Param(key: "stc", value: {Tool.convertToString(["légume":["chou","patate","tomate","carotte"], "fruits": ["pomme", "abricot", "poire"]]).value}, type: .json)
        let arrayParam = Param(key: "array", value: {Tool.convertToString(["chou", "choux-fleur"]).value}, type: .string)
        
        let refParamOptions = ParamOption()
        refParamOptions.relativePosition = ParamOption.RelativePosition.last
        
        let refParam = Param(key: "ref", value: {"www.atinternet.com"}, type: .string, options: refParamOptions)
        let dsluParam = Param(key:"dslu", value: {Tool.convertToString(10).value}, type: .integer)
        
        let crashParamOptions = ParamOption()
        crashParamOptions.relativePosition = ParamOption.RelativePosition.after
        crashParamOptions.relativeParameterKey = "stc"
        
        let crashParam = Param(key:"crash", value: {Tool.convertToString(false).value}, type: .bool, options: crashParamOptions)
        
        let hlParamOptions = ParamOption()
        hlParamOptions.persistent = true
        let hlParam = Param(key: "hl", value: {self.getDate()}, type: .string, options: hlParamOptions)
        
        tracker.buffer.volatileParameters.append(pageParam)
        tracker.buffer.volatileParameters.append(stcParam)
        tracker.buffer.volatileParameters.append(refParam)
        tracker.buffer.volatileParameters.append(dsluParam)
        tracker.buffer.volatileParameters.append(crashParam)
        tracker.buffer.persistentParameters.append(hlParam)
        tracker.buffer.volatileParameters.append(arrayParam)
        
        let builder = Builder(tracker: self.tracker, volatileParameters: tracker.buffer.volatileParameters, persistentParameters: tracker.buffer.persistentParameters)
        
        var params = builder.organizeParameters(builder.volatileParameters + builder.persistentParameters)
        
        XCTAssert(params[0].key == "p", "Le premier paramètre doit etre p=")
        XCTAssert(params[1].key == "stc", "Le second paramètre doit etre stc=")
        XCTAssert(params[2].key == "crash", "Le troisième paramètre doit etre crash=")
        XCTAssert(params[3].key == "dslu", "Le quatrième paramètre doit etre dslu=")
        XCTAssert(params[4].key == "array", "Le cinquième paramètre doit etre array=")
        #if os(iOS)
        XCTAssert(params[19].key == "hl", "Le sixième paramètre doit etre hl=")
        XCTAssert(params[20].key == "ref", "Le septième paramètre doit etre ref=")
        #elseif os(tvOS)
        XCTAssert(params[18].key == "hl", "Le sixième paramètre doit etre hl=")
        XCTAssert(params[19].key == "ref", "Le septième paramètre doit etre ref=")
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
            let param = Param(key:"bigparameter\(i)", value: {Tool.convertToString("bigvalue\(i)").value}, type: .string)
            tracker.buffer.volatileParameters.append(param)
        }
        
        let builder = Builder(tracker: self.tracker, volatileParameters: tracker.buffer.volatileParameters, persistentParameters: tracker.buffer.persistentParameters)
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
        
        let param = Param(key:"ati", value: {Tool.convertToString(array).value}, type: .string)
        tracker.buffer.volatileParameters.append(param)
        let builder = Builder(tracker: self.tracker, volatileParameters: tracker.buffer.volatileParameters, persistentParameters: tracker.buffer.persistentParameters)
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
        
        let param = Param(key:"ati", value: {Tool.convertToString(json).value}, type: .json)
        tracker.buffer.volatileParameters.append(param)
        let builder = Builder(tracker: self.tracker, volatileParameters: tracker.buffer.volatileParameters, persistentParameters: tracker.buffer.persistentParameters)
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
        
        let param = Param(key:"var", value: {Tool.convertToString(array).value}, type: .string)
        tracker.buffer.volatileParameters.append(param)
        let builder = Builder(tracker: self.tracker, volatileParameters: tracker.buffer.volatileParameters, persistentParameters: tracker.buffer.persistentParameters)
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
