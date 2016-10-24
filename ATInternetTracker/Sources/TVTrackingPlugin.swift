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
//  TVTracking.swift
//  Tracker
//

import Foundation

/// TVTracking Plugin
class TVTrackingPlugin: Plugin {
    
    enum TVTrackingConstant: String {
        case tvtParam = "ATTVTParam"
        case lastSessionStart = "ATTVTLastSessionStart"
        case remanentSpot = "ATTVTRemanentSpot"
        case version = "1.2.2m"
    }
    
    enum TVTrackingStatusCase {
        case channelUndefined
        case channelError
        case noData
        case timeError
        case ok
    }
    
    private var statusCase = TVTrackingStatusCase.ok
    private var timeData = ""
    
    /// User Defaults
    let userDefaults = NSUserDefaults.standardUserDefaults()

    /// Spot
    private var _spot = [String: AnyObject]()
    var spot: [String: AnyObject] {
        
        get {
            if (self._spot["priority"] == nil) {
                self._spot["priority"] = "30"
            }
            
            if (self._spot["lifetime"] == nil) {
                self._spot["lifetime"] = "1"
            }
            
            return self._spot
        }
        
        set {
            self._spot = newValue
        }
        
    }
    
    /// Indique que les informations du spot sont valides
    var isValidSpot: Bool {
        get {
            if let value = spot["channel"] as? String {
                if (value != "undefined") {
                    if let optPartnerTime = spot["time"] as? String{
                        timeData = optPartnerTime;
                        let dateFormatter = NSDateFormatter()
                        dateFormatter.locale = LifeCycle.locale
                        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
                        dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC")
                        
                        if let optDate = dateFormatter.dateFromString(optPartnerTime){
                            let tvtSpotValidityTime = Int(tracker.configuration.parameters["tvtSpotValidityTime"]!)
                            
                            if(Tool.minutesBetweenDates(optDate, toDate: NSDate()) > tvtSpotValidityTime){
                                statusCase = TVTrackingStatusCase.timeError
                                return false
                            } else {
                                return true
                            }
                        } else {
                            statusCase = TVTrackingStatusCase.timeError
                            return false
                        }
                        
                    } else {
                        statusCase = TVTrackingStatusCase.timeError
                        return false
                    }
                } else {
                    statusCase = TVTrackingStatusCase.channelUndefined
                    return false
                }
            } else {
                statusCase = TVTrackingStatusCase.channelError
                return false
            }
        }
    }
    
    /// Indique si un spot a déjà été sauvegardé ou non
    var isSpotFirstTimeSaved: Bool {
        get {
            return (userDefaults.objectForKey(TVTrackingConstant.tvtParam.rawValue) == nil)
        }
    }
    
    /// Indique si la visite est terminée ou non
    var isVisitOver: Bool {
        get {
            var isOver = false
            
            let lastSession = userDefaults.objectForKey(TVTrackingConstant.lastSessionStart.rawValue) as? NSDate
            
            let diffTimeSession = NSDate().timeIntervalSinceDate(lastSession!)
            
            if ((diffTimeSession / 60 > Double(tracker.tvTracking.visitDuration)) || isSpotFirstTimeSaved) {
                userDefaults.setObject(NSDate(), forKey: TVTrackingConstant.lastSessionStart.rawValue)
                userDefaults.synchronize()
                
                isOver = true
            } else if (diffTimeSession / 60 < Double(tracker.tvTracking.visitDuration)) {
                userDefaults.setObject(NSDate(), forKey: TVTrackingConstant.lastSessionStart.rawValue)
                userDefaults.synchronize()
            }
            
            return isOver
        }
    }
    
    override func execute() {
        
        if (isSpotFirstTimeSaved) {
            userDefaults.setObject(NSDate(), forKey: TVTrackingConstant.lastSessionStart.rawValue)
            userDefaults.synchronize()
        }
 
        if (isVisitOver) {
            
            userDefaults.setObject(NSDate(), forKey: TVTrackingConstant.lastSessionStart.rawValue)
            userDefaults.synchronize()
            
            let semaphore = dispatch_semaphore_create(0)
            
            let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration();
            sessionConfig.requestCachePolicy = .ReloadIgnoringLocalCacheData;
            sessionConfig.timeoutIntervalForRequest = 5.0
            
            if let url = tracker.tvTracking.campaignURL {
                let request = NSURLRequest(URL: url)
                let session = NSURLSession(configuration: sessionConfig)
                
                let task = session.dataTaskWithRequest(request, completionHandler: {(data, response, error) in

                    self.response = Tool.JSONStringify(self.buildTVTParam(data, urlResponse: response, error: error), prettyPrinted: false)
                    self.tracker.delegate?.didCallPartner?("TV Tracking: " + self.response)
                    
                    session.finishTasksAndInvalidate()
                    
                    dispatch_semaphore_signal(semaphore)
                })
                
                task.resume()
            }
            
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
            
        } else {
            
            let param = userDefaults.objectForKey(TVTrackingConstant.tvtParam.rawValue) as! [String: AnyObject]
            response = Tool.JSONStringify(param, prettyPrinted: false)
        }
    }
    
    func buildTVTParam(data: NSData!, urlResponse: NSURLResponse!, error: NSError!) -> [String: AnyObject] {
        
        var tvtParam = [String: [String: AnyObject]]()
        
        var spotSet = false
        
        if data != nil && error == nil {
            
            if let serializedData = (try? NSJSONSerialization.JSONObjectWithData(data, options: [])) as? [String: AnyObject] {
                spot = serializedData
                spotSet = true
                
                var directSpot = [String: AnyObject]()
                directSpot["direct"] = spot
                
                if (isValidSpot) {
                    tvtParam["tvtracking"] = directSpot
                } else {
                    tvtParam["tvtracking"] = [String: AnyObject]()
                }
                
            } else {
                
                statusCase = TVTrackingStatusCase.noData
                
            }
            
        } else {
            
            statusCase = TVTrackingStatusCase.noData
            
        }
        
        let remanentSpot = userDefaults.objectForKey(TVTrackingConstant.remanentSpot.rawValue) as? [String: AnyObject]
        
        if let remanentSpot = remanentSpot {
            
            let date = remanentSpot["date"] as! NSDate
            let diffTime = Int(round(NSDate().timeIntervalSinceDate(date)))
            
            var remanentSpotContent = [String: AnyObject]()
            remanentSpotContent["remanent"] = remanentSpot["spot"]
            
            let r = remanentSpotContent["remanent"] as! [String: AnyObject]
            let lifetime = r["lifetime"] as! String
            
            if ( (diffTime / (60*60*24)) < Int(lifetime) ) {
                if !spotSet {
                    tvtParam["tvtracking"] = ["remanent": remanentSpot["spot"]!]
                } else {
                    tvtParam["tvtracking"]!["remanent"] = remanentSpot["spot"]
                }
            } else {
                userDefaults.removeObjectForKey(TVTrackingConstant.remanentSpot.rawValue)
                userDefaults.synchronize()
            }
            
            if (spotSet && isValidSpot) {
                tvtParam["tvtracking"]!["direct"] = spot
            }
            
        }
        
        if tvtParam["tvtracking"] == nil {
            tvtParam["tvtracking"] = [String: String]();
        }
        
        tvtParam["tvtracking"]!["info"] = buildTVTInfo(urlResponse)
        
        if (spotSet
            && isValidSpot
            && (isSpotFirstTimeSaved || spot["priority"] as? String == "1")) {
                
            userDefaults.setObject(["spot": spot, "date": NSDate()], forKey: TVTrackingConstant.remanentSpot.rawValue)
            userDefaults.synchronize()
                
        }
        
        userDefaults.setObject(tvtParam, forKey: TVTrackingConstant.tvtParam.rawValue)
        userDefaults.synchronize()
        
        return tvtParam
        
    }
    
    func buildTVTInfo(response: NSURLResponse!) -> [String: String] {
        
        var dic = [String: [String: String]]()
        dic["info"] = [String: String]()
        
        var code = "Unknown"
        
        if response != nil {
            if let response = response as? NSHTTPURLResponse {
                code = String(response.statusCode)
            }
        }
        
        dic["info"]!["version"] = TVTrackingConstant.version.rawValue
        
        switch statusCase {
        case .channelError:
            dic["info"]!["message"] = code
            dic["info"]!["errors"] = "noChannel"
        case .channelUndefined:
            dic["info"]!["message"] = code + "-" + "channelUndefined"
        case .noData:
            dic["info"]!["message"] = code
            dic["info"]!["errors"] = "noData"
        case .timeError:
            dic["info"]!["message"] = code + "-" + timeData
            dic["info"]!["errors"] = "timeError"
        default:
            dic["info"]!["message"] = code
        }
        
        return dic["info"]!
        
    }
    
}
