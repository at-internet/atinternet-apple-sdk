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


import Foundation

class SmartTrackerConfiguration {
    
    private let ebs = [
        "dev"       : "https://tag-smartsdk-dev.atinternet-solutions.com/",
        "preprod"   : "https://tag-smartsdk-preprod.atinternet-solutions.com/",
        "prod"       : "https://smartsdk.atinternet-solutions.com"
    ]

    
    private let apiConf = [
        "dev"       : "https://8me4zn67yd.execute-api.eu-west-1.amazonaws.com/dev/token/{token}/version/{version}",
        "preprod"       : "https://8me4zn67yd.execute-api.eu-west-1.amazonaws.com/preprod/token/{token}/version/{version}",
        "prod"           : "https://8me4zn67yd.execute-api.eu-west-1.amazonaws.com/prod/token/{token}/version/{version}",
    ]
    
    private let apiCheck = [
        "dev"          : "https://8me4zn67yd.execute-api.eu-west-1.amazonaws.com/dev/token/{token}/version/{version}/lastUpdate",
        "preprod"       : "https://8me4zn67yd.execute-api.eu-west-1.amazonaws.com/preprod/token/{token}/version/{version}/lastUpdate",
        "prod"           : "https://8me4zn67yd.execute-api.eu-west-1.amazonaws.com/prod/token/{token}/version/{version}/lastUpdate",
    ]

    static let sharedInstance = SmartTrackerConfiguration()
    let env: String
    
    private init() {
        let plist = Bundle(for: Tracker.self).path(forResource: "DefaultConfiguration", ofType: "plist")
        let environment = NSDictionary(contentsOfFile: plist!)?.object(forKey: "atEnv") as? String
        //assert(environment != nil, "something went wrong, AT-env is not set")
        env = environment ?? "prod"
    }
    
    func getEndPoint(zone: [String: String]) -> String {
        let endPoint = zone[env]
        return endPoint!
    }
    
    var ebsEndpoint: String {
        return getEndPoint(zone: ebs)
    }
    
    var apiCheckEndPoint: String {
        return getEndPoint(zone: apiCheck)
    }
    
    var apiConfEndPoint: String {
        return getEndPoint(zone: apiConf)
    }
}
