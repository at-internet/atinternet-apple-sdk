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
class Builder: Operation {
    /// Tracker instance
    var tracker: Tracker
    /// Contains persistent parameters
    var persistentParameters: [String:Param]
    /// Contains non persistent parameters
    var volatileParameters: [String:Param]
    
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
    init(tracker: Tracker) {
        self.tracker = tracker
        self.volatileParameters = tracker.buffer.volatileParameters
        self.persistentParameters = tracker.buffer.persistentParameters
    }
    
    /**
    Builds first half of the hit with configuration parameters
    
    - returns: A string which represent the beginning of the hit
    */
    func buildConfiguration() -> String {
        var hitConf: String = ""
        var hitConfChunks = 0
        
        if (self.tracker.configuration.parameters[sslKey]?.lowercased() == "true") {
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
        for parameterKey in formattedParams.keys {
            guard let value = formattedParams[parameterKey]?.0, let separator = formattedParams[parameterKey]?.1 else {
                continue
            }
            
            // If the queryString length is too long
            if (value.characters.count > refMaxSize) {
                
                // Check if the concerned parameter value in the queryString is allowed to be sliced
                if (SliceReadyParam.list.contains(parameterKey)) {
                    
                    // We slice the parameter value on the parameter separator
                    let components = value.components(separatedBy: "=")
                    let valChunks = components[1].components(separatedBy: separator)
                    
                    // Parameter key to re-add on each chunks where the value is spread
                    var keyAdded = false
                    let keySplit = "&" + parameterKey + "="
                    
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
                                let idxMax = hit.index(hit.startIndex, offsetBy: refMaxSize - errQuery.characters.count)
                                hit = "\(hit[..<idxMax])"
                                // Check if in the last 5 characters there is misencoded character, if so we truncate again
                                let idxEncode = hit.index(hit.endIndex, offsetBy: -5)
                                let lastChars = hit[...idxEncode]
                                let rangeMisencodedChar = lastChars.range(of: "%")
                                if rangeMisencodedChar != nil {
                                    let idx = hit.index(hit.startIndex, offsetBy: hit.characters.count - 5)
                                    hit = "\(hit[..<idx])"
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
            } else if ((hit+value).characters.count <= refMaxSize) {
                hit += value
            
            // Else, we add a new hit
            } else {
                chunksCount += 1
                hits.append(hit)
                hit = value
                
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
            delegate.buildDidEnd?(HitStatus.success, message: message)
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
                mhOlt = String(format: "%f", Date().timeIntervalSince1970)
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
    func organizeParameters(_ parameters: [String:Param]) -> [Param] {
        var parameters = parameters
        var params = Array<Param>()
        var lastParameter: Param?
        var firstParameter: Param?
        let refParameter = parameters.removeValue(forKey: HitParam.referrer.rawValue)
        
        for (_, p) in parameters {
            guard let option = p.options else {
                params.append(p)
                continue
            }
            if option.relativePosition == .first {
                firstParameter = p
            }
            else if option.relativePosition == .last {
                lastParameter = p
            }
            else {
                params.append(p)
            }
        }
        
        
        
        // Add the parameter marked as "first" in the collection if there is one
        if let first = firstParameter {
            params.insert(first, at: 0)
        }
        
        // Add the parameter marked as "last" in the collection if there is one
        if let last = lastParameter {
            params.append(last)
        }
        
        // Always add the parameter ref, if it exists, in last position
        if let ref = refParameter {
            params.append(ref)
        }
        
        return params;
    }
        
    /**
    Prepares parameters (organize, stringify, encode) stored in the buffer to be used in the hit
    
    - returns: An array of prepared parameters
    */
    func prepareQuery() -> Dictionary<String, (String, String)> {
        var formattedParameters = Dictionary<String, (String, String)>()
        
        var buffer = [String:Param]()
        persistentParameters.forEach { (k,v) in buffer[k] = v }
        volatileParameters.forEach { (k,v) in buffer[k] = v }
        
        // Plugin management
        if buffer["tvt"] != nil {
            if let optPlugin = PluginParam.list(tracker)["tvt"] {
                let plugin = optPlugin.init(tracker: tracker)
                plugin.execute()
                buffer["stc"]?.values.append({plugin.response})
            }
        }
        
        let bufferParams = organizeParameters(buffer)
        
        for p in bufferParams {
            var paramValues = Array(p.values)
            var strValue = paramValues.remove(at: 0)()
            
            if let json = parseJSON(str: strValue) {
                if json is Dictionary<String, Any> {
                    var result = Dictionary<String, Any>()
                    for (key, val) in json as! Dictionary<String, Any> {
                        result[key] = val
                    }
                    
                    for closureValue in paramValues {
                        let appendValue = closureValue()
                        let appendValueJSON = parseJSON(str: appendValue)
                        if appendValueJSON != nil && appendValueJSON is Dictionary<String, Any> {
                            for (key, val) in appendValueJSON as! Dictionary<String, Any> {
                                result[key] = val
                            }
                        } else {
                            tracker.delegate?.warningDidOccur?("Could not append value to json object")
                        }
                    }
                    strValue = createJSON(object: result);
                }
                if json is Array<Any> {
                    var result = Array<Any>()
                    for p in json as! Array<Any> {
                        result.append(p)
                    }
                    for closureValue in paramValues {
                        let appendValue = closureValue()
                        let appendValueJSON = parseJSON(str: appendValue)
                        if appendValueJSON != nil && appendValueJSON is Array<Any> {
                            for val in appendValueJSON as! Array<Any> {
                                result.append(val)
                            }
                        }
                    }
                    strValue = result.description
                }
            }
            else {
                for closureValue in paramValues {
                    strValue += p.options?.separator ?? ","
                    strValue += closureValue()
                }
            }
            
            if p.key == HitParam.userID.rawValue {
                if TechnicalContext.doNotTrack {
                    strValue = "opt-out"
                }
                else if let hash = self.tracker.configuration.parameters["hashUserId"] {
                    if (hash.lowercased() == "true") {
                        strValue = strValue.sha256Value
                    }
                }
            }
            else if p.key == HitParam.referrer.rawValue {
                strValue = strValue.replacingOccurrences(of: "&", with: "$")
                    .replacingOccurrences(of: "<", with: "")
                    .replacingOccurrences(of: ">", with: "")
            }
            
            var separator = p.options?.separator ?? ","
            if let opts = p.options, opts.encode == true {
                strValue = strValue.percentEncodedString
                separator = opts.separator.percentEncodedString
            }
            
            formattedParameters[p.key] = (self.makeSubQuery(p.key, value: strValue), separator)
        }
        return formattedParameters
    }
    func parseJSON(str: String) -> Any? {
        let data = str.data(using: String.Encoding.utf8, allowLossyConversion: false)
        guard let jsonData = data else { return nil }
        do { return try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers) }
        catch { return nil }
    }
    func createJSON(object: Any) -> String {
        if let JSON = try? JSONSerialization.data(withJSONObject: object, options: []) {
            return String(data: JSON, encoding: .utf8) ?? ""
        }
        return ""
    }
    
    /**
    Builds the querystring parameters
    
    - parameter parameter: key
    - parameter parameter: value
    
    - returns: A string containing a querystring parameter
    */
    func makeSubQuery(_ parameter: String, value: String) -> String {
        return String(format: "&%@=%@", parameter, value)
    }
    
    /**
    Builds a mhid suffix parameter
    
    - returns: A string mhid suffix
    */
    func mhidSuffixGenerator() -> String {
        let randId = arc4random_uniform(10000000)
        let date = Date()
        let calendar = NSCalendar.current
        let components = (calendar as NSCalendar).components([.hour, .minute, .second], from: date)
        let h: Int = components.hour ?? 0
        let m = components.minute ?? 0
        let s = components.second ?? 0
        return ("\(h)\(m)\(s)\(randId)")
    }
}
