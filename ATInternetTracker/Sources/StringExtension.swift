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
//  StringExtension.swift
//  Tracker
//

import Foundation
#if canImport(CryptoKit)
import CryptoKit
#endif

/// Properties for extending String object
extension String {    
    /// Returns a percent encoded string
    var percentEncodedString: String {
        let toEncodeSet = CharacterSet(charactersIn:"! #$@'()*+,/:;=?@[]\"%-.<>\\^_{}|~&").inverted
        return self.addingPercentEncoding(withAllowedCharacters: toEncodeSet)!
    }
    
    /// Returns a percent decoded sgtring
    var percentDecodedString:String {
        if let decodedString = self.removingPercentEncoding {
            return decodedString
        } else {
            return ""
        }
    }
    
    var sha256Value: String {
      if #available(iOS 13.0, *) {
        let base = "AT" + self
        let hashed = SHA256.hash(data: base.data(using: .utf8)!)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
      } else {
        return Hash.sha256Value("AT" + self)
      }
    }
    
    /**
     Converts a String into a NSDictionary or NSArray
     
     - returns: NSDictionary or NSArray
     */
    func toJSONObject() -> Any? {
        let data = self.data(using: String.Encoding.utf8, allowLossyConversion: false)
        if let jsonData = data {
            // Will return an object or nil if JSON decoding fails
            return try? JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers)
        } else {
            // Lossless conversion of the string was not possible
            return nil
        }
    }
    
    func toBool() -> Bool {
        return self == "True"
        || self == "true"
        || self == "yes"
        || self == "1"
    }
    
    /**
    Removes white spaces inside of a string
    
    - returns: a string
    */
    func removeSpaces() -> String {
        return self.replacingOccurrences(of: " ", with: "", options: NSString.CompareOptions.literal, range: nil)
    }
}
