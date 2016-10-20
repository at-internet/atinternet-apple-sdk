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
    
    fileprivate var statusCase = TVTrackingStatusCase.ok
    fileprivate var timeData = ""
    
    /// User Defaults
    let userDefaults = UserDefaults.standard

    /// Spot
    fileprivate var _spot = [String: Any]()
    var spot: [String: Any] {
        
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
                        let dateFormatter = DateFormatter()
                        dateFormatter.locale = LifeCycle.locale
                        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
                        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
                        
                        if let optDate = dateFormatter.date(from: optPartnerTime){
                            let tvtSpotValidityTime = Int(tracker.configuration.parameters["tvtSpotValidityTime"] ?? "") ?? 5
                            
                            if(Tool.minutesBetweenDates(optDate, toDate: Date()) > tvtSpotValidityTime){
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
            return (userDefaults.object(forKey: TVTrackingConstant.tvtParam.rawValue) == nil)
        }
    }
    
    /// Indique si la visite est terminée ou non
    var isVisitOver: Bool {
        get {
            var isOver = false
            
            let lastSession = userDefaults.object(forKey: TVTrackingConstant.lastSessionStart.rawValue) as? Date
            
            let diffTimeSession = Date().timeIntervalSince(lastSession!)
            
            if ((diffTimeSession / 60 > Double(tracker.tvTracking.visitDuration)) || isSpotFirstTimeSaved) {
                userDefaults.set(Date(), forKey: TVTrackingConstant.lastSessionStart.rawValue)
                userDefaults.synchronize()
                
                isOver = true
            } else if (diffTimeSession / 60 < Double(tracker.tvTracking.visitDuration)) {
                userDefaults.set(Date(), forKey: TVTrackingConstant.lastSessionStart.rawValue)
                userDefaults.synchronize()
            }
            
            return isOver
        }
    }
    
    override func execute() {
        if (isSpotFirstTimeSaved) {
            userDefaults.set(Date(), forKey: TVTrackingConstant.lastSessionStart.rawValue)
            userDefaults.synchronize()
        }
        
        if (isVisitOver) {
            
            userDefaults.set(Date(), forKey: TVTrackingConstant.lastSessionStart.rawValue)
            userDefaults.synchronize()
            
            let semaphore = DispatchSemaphore(value: 0)
            
            let sessionConfig = URLSessionConfiguration.default;
            sessionConfig.requestCachePolicy = .reloadIgnoringLocalCacheData;
            sessionConfig.timeoutIntervalForRequest = 5.0
            
            if let url = tracker.tvTracking.campaignURL {
                let request = URLRequest(url: url as URL)
                let session = URLSession(configuration: sessionConfig)
                
                let task = session.dataTask(with: request, completionHandler: {(data, response, error) in
                    
                    self.response = Tool.JSONStringify(self.buildTVTParam(data, urlResponse: response, error: error as NSError!), prettyPrinted: false)
                    self.tracker.delegate?.didCallPartner?("TV Tracking: " + self.response)
                    
                    session.finishTasksAndInvalidate()
                    
                    semaphore.signal()
                })
                
                task.resume()
            }
            
            _ = semaphore.wait(timeout: DispatchTime.distantFuture)
            
        } else {
            
            let param = userDefaults.object(forKey: TVTrackingConstant.tvtParam.rawValue) as! [String: Any]
            response = Tool.JSONStringify(param, prettyPrinted: false)
        }
    }
    
    func buildTVTParam(_ data: Data!, urlResponse: URLResponse!, error: NSError!) -> [String: Any] {
        
        var tvtParam = [String: [String: Any]]()
        
        var spotSet = false
        
        if data != nil && error == nil {
            
            if let serializedData = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String: Any] {
                spot = serializedData
                spotSet = true
                
                var directSpot = [String: Any]()
                directSpot["direct"] = spot
                
                if (isValidSpot) {
                    tvtParam["tvtracking"] = directSpot
                } else {
                    tvtParam["tvtracking"] = [String: Any]()
                }
                
            } else {
                
                statusCase = TVTrackingStatusCase.noData
                
            }
            
        } else {
            
            statusCase = TVTrackingStatusCase.noData
            
        }
        
        let remanentSpot = userDefaults.object(forKey: TVTrackingConstant.remanentSpot.rawValue) as? [String: Any]
        
        if let remanentSpot = remanentSpot {
            
            let date = remanentSpot["date"] as! Date
            let diffTime = Int(round(Date().timeIntervalSince(date)))
            
            var remanentSpotContent = [String: Any]()
            remanentSpotContent["remanent"] = remanentSpot["spot"]
            
            let r = remanentSpotContent["remanent"] as! [String: Any]
            let lifetime = r["lifetime"] as? String ?? "30"
            
            if ( (diffTime / (60*60*24)) < Int(lifetime) ?? 30) {
                if !spotSet {
                    tvtParam["tvtracking"] = ["remanent": remanentSpot["spot"]!]
                } else {
                    tvtParam["tvtracking"]!["remanent"] = remanentSpot["spot"]
                }
            } else {
                userDefaults.removeObject(forKey: TVTrackingConstant.remanentSpot.rawValue)
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
                
            userDefaults.set(["spot": spot, "date": Date()], forKey: TVTrackingConstant.remanentSpot.rawValue)
            userDefaults.synchronize()
                
        }
        
        userDefaults.set(tvtParam, forKey: TVTrackingConstant.tvtParam.rawValue)
        userDefaults.synchronize()
        
        return tvtParam
        
    }
    
    func buildTVTInfo(_ response: URLResponse!) -> [String: String] {
        
        var dic = [String: [String: String]]()
        dic["info"] = [String: String]()
        
        var code = "Unknown"
        
        if response != nil {
            if let response = response as? HTTPURLResponse {
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
