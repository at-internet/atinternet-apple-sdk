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


typealias MappingRequest = (url: URL, onLoaded: (JSON?) -> (), onError: () -> ())
/**
 *  Simple storage protocol
 */
protocol SimpleStorageProtocol {
    /**
     Get an object by his name
     
     - parameter name: the name of the object
     
     - returns: the object or nil
     */
    func getByName(_ name: String) -> Any?
    /**
     Save an object by his name
     
     - parameter config: the object
     - parameter name:   the name of the object
     
     - returns: true if success
     */
    func saveByName(_ config: Any, name: String) -> Bool
}

/// Simple storage impl with UserDefault
class UserDefaultSimpleStorage: SimpleStorageProtocol {
    /**
     get from user default
     
     - parameter name: a name
     
     - returns: the object
     */
    func getByName(_ name: String) -> Any? {
        let userDefault = UserDefaults.standard
        return userDefault.object(forKey: name)
    }
    
    /**
     save to user default
     
     - parameter config: an object
     - parameter name:   the name
     
     - returns: true if success
     */
    func saveByName(_ config: Any, name: String) -> Bool {
        let userDefault = UserDefaults.standard
        userDefault.set(config, forKey: name)
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
    func getURL(_ request: MappingRequest, retryCount: Int)
}

/// Light network service impl with error handling
class S3NetworkService: SimpleNetworkService {
    
    /// retry wrapper for getURL
    func retry( _ f: (MappingRequest, Int) -> (), request: MappingRequest, retryCount: Int) -> () {
        if retryCount >= 0 {
            sleep(3+arc4random_uniform(5))
            f((request.url, request.onLoaded, request.onError), retryCount)
        } else {
            request.onError()
        }
    }
    
    func getURL(_ request: MappingRequest, retryCount: Int) {
        var urlRequest = URLRequest(url: request.url, cachePolicy: URLRequest.CachePolicy.reloadIgnoringLocalCacheData, timeoutInterval: 30)
        urlRequest.httpMethod = "GET"
        
        let session = URLSession.shared
        let task = session.dataTask(with: urlRequest) { (data, urlResponse, err) in
            if let _ = err {
                self.retry(self.getURL, request: (url: request.url, onLoaded: request.onLoaded, onError: request.onError), retryCount: retryCount-1)
            }
            if let jsonData = data {
                let res = JSON(data: jsonData)
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
    func getMappingURL() -> URL {
        return URL(string:S3URL
            .replacingOccurrences(of: "{token}", with: self.token)
            .replacingOccurrences(of: "{version}", with: self.version)
        )!
    }
    
    /**
     get the check url
     
     - returns: the url
     */
    fileprivate func getCheckURL() -> URL {
        return URL(string:S3URLCheck
            .replacingOccurrences(of: "{token}", with: self.token)
            .replacingOccurrences(of: "{version}", with: self.version)
        )!
    }

    func fetchSmartSDKMapping(_ onLoaded: @escaping (JSON?) -> (), onError: @escaping () -> ()) {
        network.getURL((getMappingURL(), onLoaded: onLoaded, onError: onError), retryCount: 5)
    }

    /**
     save the config
     
     - parameter mapping: the config
     */
    func saveSmartSDKMapping(_ mapping: JSON) {
        _ = store.saveByName(mapping.object, name: "at_smartsdk_config")
    }
    
    /**
     get the config
     
     - returns: the config
     */
    fileprivate func getSmartSDKMapping() -> JSON? {
        let jsonObj = store.getByName("at_smartsdk_config")
        if let obj = jsonObj {
            return JSON(obj)
        }
        return nil
    }
    
    /**
     get the checksum - actually it's a timestamp used to know if we need to fetch the configuration or not
     
     - parameter callback: the checksum
     */
    fileprivate func fetchCheckSum(_ callback: @escaping (JSON?) -> ()) {
        
        func err() -> () {
            callback(nil)
        }
        
        network.getURL((getCheckURL(), onLoaded: callback, onError: err), retryCount: 1)
    }
    
    /**
     Main method - get the most recent configuration from the network/cache
     
     - parameter callback: the configuration
     */
    func fetchMapping(_ callback: @escaping (JSON?) -> ()) {
        func getRemoteMapping(_ callback: @escaping (JSON?) -> ()) {
            self.fetchSmartSDKMapping({ (mapping: JSON?) in
                callback(mapping)
                }, onError: {
                    callback(nil)
            })
        }
        
        if let localMapping = getSmartSDKMapping() {
            let localTimestamp = localMapping["timestamp"].intValue
            fetchCheckSum({ (remote: JSON?) in
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
