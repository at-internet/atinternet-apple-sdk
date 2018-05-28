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

/// Lifecycle keys
enum SSDKStorageKeys: String, EnumCollection {
    case Config = "at_smartsdk_config"
    case TTL = "at_smartsdk_ttl"
}

typealias MappingRequest = (url: URL, callback: (ATJSON?) -> ())
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
    func getURL(_ request: MappingRequest)
}

/// Light network service impl with error handling
class S3NetworkService: SimpleNetworkService {
    
    func getURL(_ request: MappingRequest) {
        var urlRequest = URLRequest(url: request.url, cachePolicy: URLRequest.CachePolicy.reloadIgnoringLocalCacheData, timeoutInterval: 30)
        urlRequest.httpMethod = "GET"
        
        let session = URLSession.shared
        let task = session.dataTask(with: urlRequest) { (data, urlResponse, err) in
            if let _ = err {
                request.callback(nil)
            }
            if let jsonData = data {
                let res = ATJSON(data: jsonData)
                if res["type"] >= 400 {
                    request.callback(nil)
                }
                else {
                    request.callback(res)
                }
            }
        }
        task.resume()
    }
}

/// Class handling the  loading of the LiveTagging configuration file
class ApiS3Client {
    let S3URL: String
    let store: SimpleStorageProtocol
    let network: SimpleNetworkService
    let token: String
    let version: String

    init(token: String, version: String, store: SimpleStorageProtocol, networkService: SimpleNetworkService, endPoint: String) {
        self.token = token
        self.version = version
        self.store = store
        self.network = networkService
        self.S3URL = endPoint
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
     save the config
     
     - parameter mapping: the config
     */
    func saveToLocal(_ mapping: ATJSON) {
        _ = store.saveByName(mapping.object, name: SSDKStorageKeys.Config.rawValue)
    }
    
    /**
     get the config
     
     - returns: the config
     */
    fileprivate func takeLocalMapping() -> ATJSON? {
        let jsonObj = store.getByName(SSDKStorageKeys.Config.rawValue)
        if let obj = jsonObj {
            return ATJSON(obj)
        }
        return nil
    }
    
    func saveTTL() {
        let ttl = Date().addingTimeInterval(TimeInterval(3600+arc4random_uniform(60*20)))
        _ = store.saveByName(ttl, name: SSDKStorageKeys.TTL.rawValue)
    }
    
    func shouldRefreshMapping() -> Bool {
        if ATInternet.sharedInstance.defaultTracker.enableLiveTagging {
            return true
        }
        if let ttl = store.getByName(SSDKStorageKeys.TTL.rawValue) as? Date {
            if ttl > Date() {
                return false
            }
        }
        return true
    }
    
    func fetchMapping(_ callback: @escaping (ATJSON?) -> ()) {
        if !self.shouldRefreshMapping() {
            callback(self.takeLocalMapping())
            return
        }
        
        self.network.getURL((self.getMappingURL(), {(json: ATJSON?) in
            if let mapping = json {
                self.saveToLocal(mapping)
                self.saveTTL()
                callback(mapping)
            } else {
                callback(self.takeLocalMapping())
            }
        }))
    }
}
