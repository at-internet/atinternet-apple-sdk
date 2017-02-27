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


typealias MappingRequest = (url: NSURL, onLoaded: (ATJSON?) -> (), onError: () -> ())
/**
 *  Simple storage protocol
 */
protocol SimpleStorageProtocol {
    /**
     Get an object by his name
     
     - parameter name: the name of the object
     
     - returns: the object or nil
     */
    func getByName(name: String) -> AnyObject?
    /**
     Save an object by his name
     
     - parameter config: the object
     - parameter name:   the name of the object
     
     - returns: true if success
     */
    func saveByName(config: AnyObject, name: String) -> Bool
}

/// Simple storage impl with UserDefault
class UserDefaultSimpleStorage: SimpleStorageProtocol {
    
    /**
     get from user default
     
     - parameter name: a name
     
     - returns: the object
     */
    func getByName(name: String) -> AnyObject? {
        let userDefault = NSUserDefaults.standardUserDefaults()
        return userDefault.objectForKey(name)
    }
    
    /**
     save to user default
     
     - parameter config: an object
     - parameter name:   the name
     
     - returns: true if success
     */
    func saveByName(config: AnyObject, name: String) -> Bool {
        let userDefault = NSUserDefaults.standardUserDefaults()
        userDefault.setObject(config, forKey: name)
        return true
    }
}

/**
 *  Light network service interface for JSON download
 */
protocol SimpleNetworkService {
    /**
     Simple Network Service protocol
     
     - parameter url:        url of the ressource
     - parameter onLoaded:   callback when loaded
     - parameter onError:    callback if an error is detected
     - parameter retryCount: retrycount if error
     */
    func getURL(request: MappingRequest, retryCount: Int)
}

/// Light network service impl with error handling
class S3NetworkService: SimpleNetworkService {
    
    /// retry wrapper for getURL
    func retry( f: (MappingRequest, Int) -> (), request: MappingRequest, retryCount: Int) -> () {
        if retryCount >= 0 {
            sleep(3+arc4random_uniform(5))
            f((request.url, request.onLoaded, request.onError), retryCount)
        } else {
            request.onError()
        }
    }
    
    func getURL(request: MappingRequest, retryCount: Int) {
        let urlRequest = NSMutableURLRequest(URL: request.url, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData, timeoutInterval: 30)
        urlRequest.HTTPMethod = "GET"
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(urlRequest) { (data, urlResponse, err) in
            if let _ = err {
                self.retry(self.getURL, request: (url: request.url, onLoaded: request.onLoaded, onError: request.onError), retryCount: retryCount-1)
            }
            if let jsonData = data {
                let res = ATJSON(data: jsonData)
                if res["type"] >= 500 {
                    self.retry(self.getURL, request: (url: request.url, onLoaded: request.onLoaded, onError: request.onError), retryCount: retryCount-1)
                }
                else if res["type"] >= 400 {
                    request.onError()
                }
                else {
                    request.onLoaded(res)
                }
            }
        }
        task.resume()
        
    }
}

/// Class handling the  loading of the LiveTagging configuration file
class ApiS3Client {
    let S3URL = SmartTrackerConfiguration.sharedInstance.apiConfEndPoint
    let S3URLCheck = SmartTrackerConfiguration.sharedInstance.apiCheckEndPoint
    let store: SimpleStorageProtocol
    let network: SimpleNetworkService
    let token: String
    let version: String

    init(token: String, version: String, store: SimpleStorageProtocol, networkService: SimpleNetworkService) {
        self.token = token
        self.version = version
        self.store = store
        self.network = networkService
    }

    /**
     get the livetagging configuration mapping url
     
     - returns: the correct url
     */
    func getMappingURL() -> NSURL {
        return NSURL(string:S3URL
            .stringByReplacingOccurrencesOfString("{token}", withString: self.token)
            .stringByReplacingOccurrencesOfString("{version}", withString: self.version)
        )!
    }
    
    /**
     get the check url
     
     - returns: the url
     */
    private func getCheckURL() -> NSURL {
        return NSURL(string:S3URLCheck
            .stringByReplacingOccurrencesOfString("{token}", withString: self.token)
            .stringByReplacingOccurrencesOfString("{version}", withString: self.version)
        )!
    }

    func fetchSmartSDKMapping(onLoaded: (ATJSON?) -> (), onError: () -> ()) {
        network.getURL((getMappingURL(), onLoaded: onLoaded, onError: onError), retryCount: 5)
    }

    /**
     save the config
     
     - parameter mapping: the config
     */
    func saveSmartSDKMapping(mapping: ATJSON) {
        store.saveByName(mapping.object, name: "at_smartsdk_config")
    }
    
    /**
     get the config
     
     - returns: the config
     */
    private func getSmartSDKMapping() -> ATJSON? {
        let jsonObj = store.getByName("at_smartsdk_config")
        if let obj = jsonObj {
            return ATJSON(obj)
        }
        return nil
    }
    
    /**
     get the checksum - actually it's a timestamp used to know if we need to fetch the configuration or not
     
     - parameter callback: the checksum
     */
    private func fetchCheckSum(callback: (ATJSON?) -> ()) {
        func err() -> () {
            callback(nil)
        }
        
        network.getURL((getCheckURL(), onLoaded: callback, onError: err), retryCount: 1)
    }
    
    /**
     Main method - get the most recent configuration from the network/cache
     
     - parameter callback: the configuration
     */
    func fetchMapping(callback: (ATJSON?) -> ()) {
        func getRemoteMapping(callback: (ATJSON?) -> ()) {
            self.fetchSmartSDKMapping({ (mapping: ATJSON?) in
                callback(mapping)
                }, onError: {
                    callback(nil)
            })
        }
        
        if let localMapping = getSmartSDKMapping() {
            let localTimestamp = localMapping["timestamp"].intValue
            fetchCheckSum({ (remote: ATJSON?) in
                if remote == nil || remote!["timestamp"].intValue != localTimestamp {
                    getRemoteMapping(callback)
                } else {
                    callback(localMapping)
                }
            })
        } else {
            getRemoteMapping(callback)
        }
    }
}
