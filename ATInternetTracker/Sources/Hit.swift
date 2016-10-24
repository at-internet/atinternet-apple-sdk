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
                "audio": .Audio,
                "video": .Video,
                "vpre": .Video,
                "vmid": .Video,
                "vpost": .Video,
                "animation": .Animation,
                "anim": .Animation,
                "podcast": .PodCast,
                "rss": .RSS,
                "email": .Email,
                "pub": .Advertising,
                "ad": .Advertising,
                "click": .Touch,
                "AT": .AdTracking,
                "pdt": .ProductDisplay,
                "wbo": .Weborama,
                "mvt": .MVTesting,
                "screen": .Screen
            ]
        }
    }
}

public class Hit: NSObject {
    /// Standard hit type
    public enum HitType: Int {
        case Unknown = 0
        case Screen = 1
        case Touch = 2
        case Audio = 3
        case Video = 4
        case Animation = 5
        case PodCast = 6
        case RSS = 7
        case Email = 8
        case Advertising = 9
        case AdTracking = 10
        case ProductDisplay = 11
        case Weborama = 12
        case MVTesting = 13
    }
    
    /// Hit
    public var url: String
    /// Date of creation
    public var creationDate: NSDate
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
        creationDate = NSDate()
        retryCount = 0
        isOffline = false
    }
    
    /**
    Get the hit type depending on the hit url
    
    :params: an url
    
    - returns: type of hit
    */
    func getHitType() -> HitType {
        var hitType = HitType.Screen
        
        if(url != "") {
            let hitUrl = NSURL(string: self.url)
            
            if let optURL = hitUrl {
                let urlComponents = optURL.query!.componentsSeparatedByString("&")
                
                for component in urlComponents as [String] {
                    let pairComponents = component.componentsSeparatedByString("=")
                    
                    if(pairComponents[0] == "type") {
                        hitType = ProcessedHitType.list[pairComponents[1]]!
                        break
                    }
                    
                    if(pairComponents[0] == "clic" || pairComponents[0] == "click") {
                        hitType = HitType.Touch
                    }
                }
                
                return hitType

            } else {
                return HitType.Unknown
            }
        }
        
        return HitType.Unknown
    }
    
    /**
    Get the hit type depending on parameters set in buffer
    
    :params: arrays of parameters
    
    - returns: type of hit
    */
    class func getHitType(parameters: [Param]...) -> HitType {
        var params = [Param]()
        var hitType = HitType.Screen
        
        for p in parameters {
            params += p
        }
        
        for p in params {
            if(p.key == "clic" || p.key == "click" || (p.key == "type" && ProcessedHitType.list.indexForKey(p.value()) != nil)) {
                if(p.key == "type") {
                    hitType = ProcessedHitType.list[p.value()]!
                    break
                }
                
                if(p.key == "clic" || p.key == "click") {
                    hitType = HitType.Touch
                }
            }
        }
        
        return hitType
    }
}