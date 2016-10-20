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

public class Hit: NSObject {
    /// Standard hit type
    public enum HitType: Int {
        case unknown = 0
        case screen = 1
        case touch = 2
        case audio = 3
        case video = 4
        case animation = 5
        case podCast = 6
        case rss = 7
        case email = 8
        case advertising = 9
        case adTracking = 10
        case productDisplay = 11
        case weborama = 12
        case mvTesting = 13
    }
    
    /// Hit
    public var url: String
    /// Date of creation
    public var creationDate: Date
    /// Number of retry that were made to send the hit
    public var retryCount: NSNumber
    /// Indicates wheter the hit comes from storage
    public var isOffline: Bool
    /// Hit type
    public  var type: HitType {
        get {
            return getHitType()
        }
    }
    /// Description
    public var text: String {
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
                let urlComponents = optURL.query!.components(separatedBy: "&")
                
                for component in urlComponents as [String] {
                    let pairComponents = component.components(separatedBy: "=")
                    
                    if(pairComponents[0] == "type") {
                        hitType = ProcessedHitType.list[pairComponents[1]]!
                        break
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
    class func getHitType(_ parameters: [Param]...) -> HitType {
        var params = [Param]()
        var hitType = HitType.screen
        
        for p in parameters {
            params += p
        }
        
        for p in params {
            if(p.key == "clic" || p.key == "click" || (p.key == "type" && ProcessedHitType.list.index(forKey: p.value()) != nil)) {
                if(p.key == "type") {
                    hitType = ProcessedHitType.list[p.value()]!
                    break
                }
                
                if(p.key == "clic" || p.key == "click") {
                    hitType = HitType.touch
                }
            }
        }
        
        return hitType
    }
}
