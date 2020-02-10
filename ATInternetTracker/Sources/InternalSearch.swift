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
//  InternalSearch.swift
//  Tracker
//

import Foundation


/// Wrapper class for internal search tracking
public class InternalSearch: BusinessObject {
    /// Searched keywords
    @objc public var keyword: String = ""
    /// Number of page result
    @objc public var resultScreenNumber: Int = 1
    /// Position of result in list
    @objc public var resultPosition: Int = -1
    
    override init(tracker: Tracker) {
        super.init(tracker: tracker)
    }
    
    /// Create a new InternalSearch
    ///
    /// - Parameters:
    ///   - keyword: internal search keyword
    ///   - resultScreenNumber: number of screens returned
    @objc public init(keyword: String, resultScreenNumber: Int) {
        super.init()
        
        self.keyword = keyword
        self.resultScreenNumber = resultScreenNumber
    }
    
    /// Set parameters in buffer
    override func setParams() {
        let pOpt = ParamOption()
        pOpt.encode = true
        _ = tracker.setParam("mc", value: keyword, options: pOpt)
        _ = tracker.setParam("np", value: resultScreenNumber)
        
        if(resultPosition > -1) {
            _ = tracker.setParam("mcrg", value: resultPosition)
        }
    }
}

/// Wrapper class to managed
public class InternalSearches: NSObject {
    /// Tracker instance
    var tracker: Tracker
    
    /**
    InternalSearches initializer
    - parameter tracker: the tracker instance
    - returns: InternalSearches instance
    */
    init(tracker: Tracker) {
        self.tracker = tracker
    }

    /// Add an internal search
    ///
    /// - Parameters:
    ///   - keyword: keyword search
    ///   - resultScreenNumber: page number result
    /// - Returns: a new internal search instance
    @objc public func add(_ keyword: String, resultScreenNumber: Int) -> InternalSearch {
        let search = InternalSearch(tracker: tracker)
        search.keyword = keyword
        search.resultScreenNumber = resultScreenNumber
        tracker.businessObjects[search.id] = search
        
        return search
    }
    
    /// Add an internal search
    ///
    /// - Parameters:
    ///   - keyword: keyword search
    ///   - resultScreenNumber: page number result
    ///   - resultPosition: the result position in the list
    /// - Returns: a new internal search instance
    @objc public func add(_ keyword: String, resultScreenNumber: Int, resultPosition: Int) -> InternalSearch {
        let search = add(keyword, resultScreenNumber: resultScreenNumber)
        search.resultPosition = resultPosition
        
        return search
    }
}
