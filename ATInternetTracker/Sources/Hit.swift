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
//  Hit.swift
//  Tracker
//

import Foundation

/// Known hit type
class ProcessedHitType: NSObject {
    /// Set of all hit types that can be processed
    class var list: [String: Hit.HitType] {
        get {
            return [
                "audio": .audio,
                "video": .video,
                "vpre": .video,
                "vmid": .video,
                "vpost": .video,
                "animation": .animation,
                "anim": .animation,
                "podcast": .podCast,
                "rss": .rss,
                "email": .email,
                "pub": .advertising,
                "ad": .advertising,
                "click": .touch,
                "AT": .adTracking,
                "pdt": .productDisplay,
                "wbo": .weborama,
                "mvt": .mvTesting,
                "screen": .screen
            ]
        }
    }
}


/// Class to provide Hit information. A hit is an HTTP request with a querystring containing all tracking information.
@objcMembers public class Hit: NSObject {
    
    /// HitType Enum
    ///
    /// - unknown: unknown
    /// - screen: screen
    /// - touch: touch
    /// - audio: audio
    /// - video: video
    /// - animation: animation
    /// - podCast: podCast
    /// - rss: rss
    /// - email: email
    /// - advertising: advertising
    /// - adTracking: adTracking
    /// - productDisplay: productDisplay
    /// - weborama: weborama
    /// - mvTesting: mvTesting
    @objc public enum HitType: Int {
        case unknown = 0
        /// screen
        case screen = 1
        /// touch
        case touch = 2
        /// audio
        case audio = 3
        /// video
        case video = 4
        /// animation
        case animation = 5
        /// podcast
        case podCast = 6
        /// rss
        case rss = 7
        /// email
        case email = 8
        /// advertising
        case advertising = 9
        /// adTracking
        case adTracking = 10
        /// productDisplay
        case productDisplay = 11
        /// weborama
        case weborama = 12
        /// mvTesting
        case mvTesting = 13
    }
    
    /// Hit  id
    var id: String
    /// Hit url
    @objc public var url: String
    /// Date of creation
    @objc public var creationDate: Date
    /// Number of retry that were made to send the hit
    @objc public var retryCount: NSNumber
    /// Indicates wheter the hit comes from storage
    @objc public var isOffline: Bool
    /// Hit type - See HitType
    public  var type: HitType {
        get {
            return getHitType()
        }
    }
    /// Description
    @objc public var text: String {
        return url
    }
    
    /**
    Default initializer
    */
    convenience override init() {
        self.init(url: "")
    }
    
    /**
    Init hit with url
    */
    init(url: String) {
        self.url = url
        id = ""
        creationDate = Date()
        retryCount = 0
        isOffline = false
    }
    
    /**
    Get the hit type depending on the hit url
    
    :params: an url
    
    - returns: type of hit
    */
    func getHitType() -> HitType {
        var hitType = HitType.screen
        
        if(url != "") {
            let hitUrl = URL(string: self.url)
            if let optURL = hitUrl {
                
                guard let query = optURL.query else {
                    return HitType.unknown
                }
                
                let urlComponents = query.components(separatedBy: "&")
                
                for component in urlComponents as [String] {
                    let pairComponents = component.components(separatedBy: "=")
                    
                    if(pairComponents[0] == "type") {
                        if let result = ProcessedHitType.list[pairComponents[1]] {
                            hitType = result
                            break
                        }
                    }
                    
                    if(pairComponents[0] == "clic" || pairComponents[0] == "click") {
                        hitType = HitType.touch
                    }
                }
                
                return hitType

            } else {
                return HitType.unknown
            }
        }
        
        return HitType.unknown
    }
    
    /**
    Get the hit type depending on parameters set in buffer
    
    :params: arrays of parameters
    
    - returns: type of hit
    */
    
    /**
     Get the hit type depending on parameters set in buffer
     
     :params: arrays of parameters
     
     - returns: type of hit
     */
    class func getHitType(_ parameters: [String:Param]...) -> HitType {
        var params = [String:Param]()
        var hitType = HitType.screen
        
        for p in parameters {
            p.forEach { (k,v) in params[k] = v }
        }
        
        if(params["clic"] != nil || params["click"] != nil) {
            hitType = HitType.touch
        }
        
        if let type = params["type"] {
            if let result = ProcessedHitType.list[type.values[0]()] {
                hitType = result
            }
        }
        
        return hitType
    }
}
