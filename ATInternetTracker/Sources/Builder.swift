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
//  Builder.swift
//  Tracker
//

import Foundation

/// Hit builder
class Builder: NSOperation {
    /// Tracker instance
    var tracker: Tracker
    /// Contains persistent parameters
    var persistentParameters: [Param]
    /// Contains non persistent parameters
    var volatileParameters: [Param]
    
    // Number of configuration part 
    let refConfigChunks = 4
    // Constant for secure configuration key
    let sslKey = "secure"
    // Constant for log configuration key
    let logKey = "log"
    // Constant for secured log configuration key
    let sslLogKey = "logSSL"
    // Constant for site configuration key
    let siteKey = "site"
    // Constant for pixel path configuration key
    let pixelPathKey = "pixelPath"
    // Constant for domain configuration key
    let domainKey = "domain"
    // Constant for Ref parameter
    let referrerParameterKey = "ref"
    
    /**
    Hit builder initialization
    
    - parameter tracker:
    - parameter configuration:
    - parameter volatileParameters: list of all volatile parameters
    - parameter persistentParameters: list of all parameters that should be sent in all hits
    
    - returns: A builder instance with default configuration and an empty buffer
    */
    init(tracker: Tracker, volatileParameters: [Param], persistentParameters: [Param]) {
        self.tracker = tracker
        self.volatileParameters = volatileParameters
        self.persistentParameters = persistentParameters
    }
    
    /**
    Builds first half of the hit with configuration parameters
    
    - returns: A string which represent the beginning of the hit
    */
    func buildConfiguration() -> String {
        var hitConf: String = ""
        var hitConfChunks = 0
        
        if (self.tracker.configuration.parameters[sslKey]?.lowercaseString == "true") {
            if let optLogs = self.tracker.configuration.parameters[sslLogKey] {
                hitConf += "https://" + optLogs + "."
                if (optLogs != "") {
                    hitConfChunks += 1
                }
            }
        } else {
            if let optLog = self.tracker.configuration.parameters[logKey] {
                hitConf += "http://" + optLog + "."
                if (optLog != "") {
                    hitConfChunks += 1
                }
            }
        }
        
        if let optDomain = self.tracker.configuration.parameters[domainKey] {
            hitConf += optDomain
            if (optDomain != "") {
                hitConfChunks += 1
            }
        }
        
        if let optPixelPath = self.tracker.configuration.parameters[pixelPathKey] {
            hitConf += optPixelPath
            if (optPixelPath != "") {
                hitConfChunks += 1
            }
        }
        
        if let optSite = self.tracker.configuration.parameters[siteKey] {
            hitConf += "?s=" + optSite
            if (optSite != "") {
                hitConfChunks += 1
            }
        }
        
        if (hitConfChunks != refConfigChunks) {
            //On lève un erreur indiquant que la configuration est incorrecte
            tracker.delegate?.errorDidOccur?("There is something wrong with configuration: " + hitConf + ". Expected 4 configuration keys, found " + String(hitConfChunks))
            
            hitConf = ""
        }
        
        return hitConf
    }
    
    /**
    Builds the hit to be sent and slices it to chunks if too long.
    
    - returns: A [String] representing the hit(s) to be sent
    */
    func build() -> [String] {
        
        // Hit maximum length
        let hitMaxLength = 1600
        // Mhid maxium length
        let mhidMaxLength = 30
        // Added to slices olt maximum length
        let oltMaxLength = 20
        // Added to slices idclient maximum length
        let idclientMaxLength = 40
        // Added to slices separator maximum length
        let separatorMaxLength = 5

        // Hits returned and ready to be sent
        var hits = [String]()
        // Hit chunks count
        var chunksCount = 1
        // Hit max chunks
        let hitMaxChunks = 999
        
        // Hit construction holder
        var hit = ""
        // Get the first part of the hit
        let config = buildConfiguration()
        // Get the parameters from the buffer (formatted as &p=v)
        let formattedParams = prepareQuery()
        
        // Reference maximum size
        let refMaxSize = hitMaxLength
            - mhidMaxLength
            - config.characters.count
            - oltMaxLength
            - idclientMaxLength
            - separatorMaxLength
        
        // Hit slicing error
        var err = false
        let errQuery = self.makeSubQuery("mherr", value: "1")
        
        // Idclient added to slices
        let idclient = TechnicalContext.userId(tracker.configuration.parameters["identifier"])
        
        // For each prebuilt queryString, we check the length
        for queryString in formattedParams {
            
            // If the queryString length is too long
            if (queryString.str.characters.count > refMaxSize) {
                
                // Check if the concerned parameter value in the queryString is allowed to be sliced
                if (SliceReadyParam.list.contains(queryString.param.key)) {
                    
                    let separator: String
                    
                    if let optSeparator = queryString.param.options?.separator {
                        separator = optSeparator
                    } else {
                        separator = ","
                    }
                    
                    // We slice the parameter value on the parameter separator
                    let components = queryString.str.componentsSeparatedByString("=")
                    let valChunks = components[1].componentsSeparatedByString(separator)
                    
                    // Parameter key to re-add on each chunks where the value is spread
                    var keyAdded = false
                    let keySplit = "&" + queryString.param.key + "="
                    
                    // For each sliced value we check if we can add it to current hit, else we create and add a new hit
                    for valChunk in valChunks {
                        if (!keyAdded && (hit + keySplit + valChunk).characters.count <= refMaxSize) {
                            hit = hit + keySplit + valChunk
                            keyAdded = true
                        } else if (keyAdded && (hit + separator + valChunk).characters.count < refMaxSize){
                            hit = hit + separator + valChunk
                        } else {
                            chunksCount += 1
                            if (hit != "") {
                                hits.append(hit + separator)
                            }
                            hit = keySplit + valChunk
                            if (chunksCount >= hitMaxChunks) {
                                // Too much chunks
                                err = true
                                break
                            } else if (hit.characters.count > refMaxSize) {
                                // Value still too long
                                self.tracker.delegate?.warningDidOccur?("Multihits: value still too long after slicing")
                                // Truncate the value
                                let idxMax = hit.startIndex.advancedBy(refMaxSize - errQuery.characters.count)
                                hit = hit.substringToIndex(idxMax)
                                // Check if in the last 5 characters there is misencoded character, if so we truncate again
                                let idxEncode = hit.endIndex.advancedBy(-5)
                                let lastChars = hit.substringFromIndex(idxEncode)
                                let rangeMisencodedChar = lastChars.rangeOfString("%")
                                if rangeMisencodedChar != nil {
                                    let idx = hit.startIndex.advancedBy(hit.characters.count - 5)
                                    hit = hit.substringToIndex(idx)
                                }
                                hit += errQuery
                                err = true
                                break
                            }
                        }
                    }
                    
                    if (err) { break }
                    
                } else {
                    // Value can't be sliced
                    self.tracker.delegate?.warningDidOccur?("Multihits: parameter value not allowed to be sliced")
                    hit += errQuery
                    break
                }
            
            // Else if the current hit + queryString length is not too long, we add it to the current hit
            } else if ((hit+queryString.str).characters.count <= refMaxSize) {
                hit += queryString.str
            
            // Else, we add a new hit
            } else {
                chunksCount += 1
                hits.append(hit)
                hit = queryString.str
                
                // Too much chunks
                if (chunksCount >= hitMaxChunks) {
                    break
                }
            }
            
        }
        
        // We add the current working hit
        hits.append(hit)
        
        // If chunksCount > 1, we have sliced a hit
        if (chunksCount > 1) {
            
            let mhidSuffix = "-\(chunksCount)-\(self.mhidSuffixGenerator())"
            
            for index in 0...(hits.count-1) {
                
                if (index == (hitMaxChunks - 1)) {
                    // Too much chunks
                    self.tracker.delegate?.warningDidOccur?("Multihits: too much hit parts")
                    hits[index] = config+errQuery
                } else {
                    // Add the configuration, the mh variable and the idclient
                    let idToAdd = (index > 0) ? self.makeSubQuery("idclient", value: idclient) : ""
                    hits[index] = "\(config)&mh=\(index+1)\(mhidSuffix)\(idToAdd)\(hits[index])"
                }
                
            }
            
        // Only one hit
        } else {
            hits[0] = config + hits[0]
        }

        if let delegate = tracker.delegate {
            var message = ""
            for hit in hits {
                message += hit + "\n"
            }
            delegate.buildDidEnd?(HitStatus.Success, message: message)
        }
        
        return hits
    }
    
    /**
    Sends hit
    */
    override func main () {
        autoreleasepool{
            // Build the hit
            let hits = self.build()
            
            // Prepare a fixed olt in case of multihits and offline
            var mhOlt: String?
            
            if (hits.count > 1) {
                mhOlt = String(format: "%f", NSDate().timeIntervalSince1970)
            } else {
                mhOlt = nil
            }
            
            for hit in hits {
                // Wrap a hit to a sender object
                let sender = Sender(tracker: self.tracker, hit: Hit(url: hit), forceSendOfflineHits:false, mhOlt: mhOlt)
                sender.send()
            }
        }
    }
    
    /**
    Sort parameters depending on their position
    
    - parameter an: array of parameter to sort
    
    - returns: An array of sorted parameters
    */
    func organizeParameters(parameters: [Param]) -> [Param] {
        var parameters = parameters;
        
        let refParamPositions = Tool.findParameterPosition(referrerParameterKey, arrays: parameters)
        var refParamIndex = -1
        
        if(refParamPositions.count > 0) {
            refParamIndex = refParamPositions.last!.index
        }
        
        var params = [Param]()
        
        // Parameter with relative position set to last
        var lastParameter:Param?
        
        // Parameter with relative position set to first
        var firstParameter:Param?
        
        // ref= Parameter
        var refParameter:Param?
        
        // Handle ref= parameter which have to be in last position
        if(refParamIndex > -1) {
            refParameter = parameters[refParamIndex]
            parameters.removeAtIndex(refParamIndex)
            
            if let optRefParam = refParameter {
                if let optOption = optRefParam.options {
                    if(optOption.relativePosition != ParamOption.RelativePosition.none && optOption.relativePosition != ParamOption.RelativePosition.last) {
                        // Raise a warning explaining ref will always be set in last position
                        self.tracker.delegate?.warningDidOccur?("ref= parameter will be put in last position")
                    }
                }
            }
        }
        
        for parameter in parameters {
            if let optOption = parameter.options {
                switch optOption.relativePosition {
                // A parameter is set in first position
                case ParamOption.RelativePosition.first:
                    if firstParameter != nil {
                        self.tracker.delegate?.warningDidOccur?("Found more than one parameter with relative position set to first")
                        params.append(parameter)
                    } else {
                        params.insert(parameter, atIndex: 0)
                        firstParameter = parameter
                    }
                // A parameter is set in last position
                case ParamOption.RelativePosition.last:
                    if lastParameter != nil{
                        // Raise a warning explaining there are multiple parameters with a last position indicator
                        self.tracker.delegate?.warningDidOccur?("Found more than one parameter with relative position set to last")
                        params.append(parameter)
                    } else {
                        lastParameter = parameter
                    }
                // A parameter is set before an other parameter
                case ParamOption.RelativePosition.before:
                    if let optRelativeParamKey = optOption.relativeParameterKey {
                        let relativePosParam = Tool.findParameterPosition(optRelativeParamKey, arrays: parameters)
                        if(relativePosParam.count > 0) {
                            params.insert(parameter, atIndex:relativePosParam.last!.index)
                        } else {
                            params.append(parameter)
                            // Raise a warning explaining that relative parameter has not been found
                            self.tracker.delegate?.warningDidOccur?("Relative parameter with key " + optRelativeParamKey + " could not be found. Parameter will be appended")
                        }
                    }
                // A parameter is set after an other parameter
                case ParamOption.RelativePosition.after:
                    if let optRelativeParamKey = optOption.relativeParameterKey {
                        let relativePosParam = Tool.findParameterPosition(optRelativeParamKey, arrays: parameters)
                        if(relativePosParam.count > 0) {
                            params.insert(parameter, atIndex:relativePosParam.last!.index + 1)
                        } else {
                            params.append(parameter)
                            // Raise a warning explaining that relative parameter has not been found
                            self.tracker.delegate?.warningDidOccur?("Relative parameter with key " + optRelativeParamKey + " could not be found. Parameter will be appended")
                        }
                    }
                default:
                    params.append(parameter)
                }
            } else {
                params.append(parameter)
            }
        }
        
        // Add the parameter marked as "last" in the collection if there is one
        if let optLastParam = lastParameter {
            params.append(optLastParam)
        }
        
        // Always add the parameter ref, if it exists, in last position
        if let optRefParam = refParameter {
            params.append(optRefParam)
        }
        
        return params;
    }
        
    /**
    Prepares parameters (organize, stringify, encode) stored in the buffer to be used in the hit
    
    - returns: An array of prepared parameters
    */
    func prepareQuery() -> [(param: Param, str: String)] {
        var params: [(param: Param, str: String)] = []
        
        var bufferParams = persistentParameters + volatileParameters
        bufferParams = organizeParameters(bufferParams)
        
        for parameter in bufferParams {
            var value = ""
            
            // Plugin management
            if let optPlugin = PluginParam.list(tracker)[parameter.key] {
                let plugin = optPlugin.init(tracker: tracker)
                plugin.execute()
                parameter.key = plugin.paramKey
                parameter.type = plugin.responseType
                value = plugin.response
            } else {
                value = parameter.value()
            }
            
            if(parameter.type == .Closure && value.toJSONObject() != nil) {
                parameter.type = .JSON
            }
            
            // User id hash management
            if(parameter.key == HitParam.UserID.rawValue) {
                if(!TechnicalContext.doNotTrack) {
                    if let hash = self.tracker.configuration.parameters["hashUserId"] {
                        if (hash.lowercaseString == "true") {
                            value = value.sha256Value
                        }
                    }
                } else {
                    value = "opt-out"
                }
            }
            
            // Referrer processing
            if(parameter.key == HitParam.Referrer.rawValue){
                value = value.stringByReplacingOccurrencesOfString("&", withString: "$")
                            .stringByReplacingOccurrencesOfString("<", withString: "")
                            .stringByReplacingOccurrencesOfString(">", withString: "")
            }
            
            if let optOption = parameter.options {
                if(optOption.encode) {
                    value = value.percentEncodedString
                    parameter.options!.separator = optOption.separator.percentEncodedString
                }
            }


            // Handle parameter's value to append another
            var duplicateParamIndex = -1
            
            for(index, param) in params.enumerate() {
                if(param.param.key == parameter.key)
                {
                    duplicateParamIndex = index
                    break
                }
            }
                
            if(duplicateParamIndex > -1) {
                let duplicateParam = params[duplicateParamIndex]
                
                // If parameter's value is JSON
                if(parameter.type == .JSON) {
                    // parse string to JSON Object
                    let json: AnyObject? = duplicateParam.str.componentsSeparatedByString("=")[1].percentDecodedString.toJSONObject()
                    let newJson: AnyObject? = value.percentDecodedString.toJSONObject()
                    
                    switch(json) {
                    case let dictionary as NSMutableDictionary:
                        switch(newJson) {
                            case let newDictionary as [NSObject : AnyObject]:
                                dictionary.addEntriesFromDictionary(newDictionary)
                            
                                let jsonData = try? NSJSONSerialization.dataWithJSONObject(dictionary, options: [])
                                let strJsonData: String = NSString(data: jsonData!, encoding: NSUTF8StringEncoding)! as String
                                
                                params[duplicateParamIndex] = (param: duplicateParam.param, str: self.makeSubQuery(parameter.key, value: strJsonData.percentEncodedString))
                            default:
                                self.tracker.delegate?.warningDidOccur?("Couldn't append value to a dictionnary")
                        }
                    case let array as NSMutableArray:
                        switch(newJson) {
                        case let newArray as [AnyObject]:
                            let jsonData = try? NSJSONSerialization.dataWithJSONObject(array.arrayByAddingObjectsFromArray(newArray), options: [])
                            let strJsonData: String = NSString(data: jsonData!, encoding: NSUTF8StringEncoding)! as String
                            
                            params[duplicateParamIndex] = (param: duplicateParam.param, str: self.makeSubQuery(parameter.key, value: strJsonData.percentEncodedString))
                        default:
                            self.tracker.delegate?.warningDidOccur?("Couldn't append value to an array")
                        }
                    default:
                        self.tracker.delegate?.warningDidOccur?("Couldn't append a JSON")
                    }
                } else {
                    if(duplicateParam.param.type == .JSON) {
                        self.tracker.delegate?.warningDidOccur?("Couldn't append value to a JSON Object")
                    } else {
                        let separator: String
                        
                        if(parameter.options == nil) {
                            separator = ","
                        } else {
                            separator = parameter.options!.separator
                        }
                        
                        params[duplicateParamIndex] = (param: duplicateParam.param, str: duplicateParam.str + separator + value)
                    }
                }
            } else {
                let prequeryInfo: (param: Param, str: String) = (param: parameter, str: self.makeSubQuery(parameter.key, value: value))
                params.append(prequeryInfo)
            }
        }
        
        return params
    }
    
    /**
    Builds the querystring parameters
    
    - parameter parameter: key
    - parameter parameter: value
    
    - returns: A string containing a querystring parameter
    */
    func makeSubQuery(parameter: String, value: String) -> String {
        return String(format: "&%@=%@", parameter, value)
    }
    
    /**
    Builds a mhid suffix parameter
    
    - returns: A string mhid suffix
    */
    func mhidSuffixGenerator() -> String {
        let randId = arc4random_uniform(10000000)
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Hour, .Minute, .Second], fromDate: date)
        let h = components.hour
        let m = components.minute
        let s = components.second
        return ("\(h)\(m)\(s)\(randId)")
    }
}
