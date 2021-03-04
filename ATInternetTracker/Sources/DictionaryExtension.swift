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

public protocol EnumCollection: Hashable {
    static func cases() -> AnySequence<Self>
    static var allValues: [Self] { get }
}

public extension EnumCollection {
    
    static func cases() -> AnySequence<Self> {
        return AnySequence { () -> AnyIterator<Self> in
            var raw = 0
            return AnyIterator {
                let current: Self = withUnsafePointer(to: &raw) { $0.withMemoryRebound(to: self, capacity: 1) { $0.pointee } }
                guard current.hashValue == raw else {
                    return nil
                }
                raw += 1
                return current
            }
        }
    }
    
    static var allValues: [Self] {
        return Array(self.cases())
    }
}

extension Dictionary {
    mutating func append<K, V>(_ dictionaries: Dictionary<K, V>...) {
        for dict in dictionaries {
            for(key, value) in dict {
                self.updateValue(value as! Value, forKey: key as! Key)
            }
        }
    }
    
    /**
    toJson: A method to get the JSON String representation of the dictionary
    
    - returns: the JSON String representation - An Empty String if it fails
    */
    func toJSON() -> String {
        if JSONSerialization.isValidJSONObject(self) {
            if let data = try?JSONSerialization.data(withJSONObject: self, options: []) {
                if let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                    return string as String
                }
            }
        }
        return ""
    }
    
    mutating func setValue(value: Any, forKeyPath keyPath: String, separator: String) {
        var keys = keyPath.components(separatedBy: separator)
        guard let first = keys.first as? Key else { return }
        keys.remove(at: 0)
        if keys.isEmpty, let settable = value as? Value {
            self[first] = settable
            return
        }
        let rejoined = keys.joined(separator: separator)
        var subdict: [NSObject : AnyObject] = [:]
        if let sub = self[first] as? [NSObject : AnyObject] {
            subdict = sub
        }
        subdict.setValue(value: value, forKeyPath: rejoined, separator: separator)
        if let settable = subdict as? Value {
            self[first] = settable
        }
    }
    
    func valueForKeyPath<T>(keyPath: String, separator: String) -> T? {
        var keys = keyPath.components(separatedBy: separator)
        guard let first = keys.first as? Key else { return nil }
        guard let value = self[first] else { return nil }
        keys.remove(at: 0)
        if !keys.isEmpty, let subDict = value as? [NSObject : AnyObject] {
            let rejoined = keys.joined(separator: separator)
            return subDict.valueForKeyPath(keyPath: rejoined, separator: separator)
        }
        return value as? T
    }
}
