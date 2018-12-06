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
//  EcommerceEvent.swift
//  Tracker
//

public class EcommerceEvent: Event {
    
    var screen : Screen
    
    override var data: [String : Any] {
        get {
            let screenObj = parseScreenNameForEvent(screen: screen)
            if screenObj.count > 0 {
                _data["page"] = screenObj
            }
            
            let level2Obj = parseLevel2ForEvent(screen: screen)
            if level2Obj.count > 0 {
                _data["level2"] = level2Obj
            }
            return super.data
        }
    }
    
    init(action: String, screen: Screen) {
        self.screen = screen
        super.init(action: action)
    }
    
    func parseScreenNameForEvent(screen: Screen) -> [String: Any] {
        var result  = [String: Any]()
        
        result["s:name"] = screen.name
        
        if let chap1 = screen.chapter1 {
            result["s:chapter1"] = chap1
        }
        
        if let chap2 = screen.chapter2 {
            result["s:chapter2"] = chap2
        }
        
        if let chap3 = screen.chapter3 {
            result["s:chapter3"] = chap3
        }
        
        return result
    }
    
    func parseLevel2ForEvent(screen: Screen) -> [String: Any] {
        var result  = [String: Any]()
    
        if screen.level2 > 0 {
            result["s:name"] = String(screen.level2)
        }
        return result
    }
}
