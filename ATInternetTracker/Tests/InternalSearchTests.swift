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
//  InternalSearchTests.swift
//  Tracker
//

import UIKit
import XCTest

class InternalSearchTests: XCTestCase {

    lazy var internalSearch: InternalSearch = InternalSearch(tracker: Tracker())
    lazy var internalSearches: InternalSearches = InternalSearches(tracker: Tracker())
    
    func testSetInternalSearch() {
        internalSearch.keyword = "watch"
        internalSearch.resultScreenNumber = 3
        internalSearch.resultPosition = 1
        internalSearch.setEvent()
        
        XCTAssertEqual(internalSearch.tracker.buffer.volatileParameters.count, 3, "Le nombre de paramètres volatiles doit être égal à 3")
        
        XCTAssert(internalSearch.tracker.buffer.volatileParameters[0].key == "mc", "Le premier paramètre doit être mc")
        XCTAssert(internalSearch.tracker.buffer.volatileParameters[0].value() == "watch", "La valeur du premier paramètre doit être watch")
        
        XCTAssert(internalSearch.tracker.buffer.volatileParameters[1].key == "np", "Le premier paramètre doit être np")
        XCTAssert(internalSearch.tracker.buffer.volatileParameters[1].value() == "3", "La valeur du deuxième paramètre doit être 3")
        
        XCTAssert(internalSearch.tracker.buffer.volatileParameters[2].key == "mcrg", "Le premier paramètre doit être mcfg")
        XCTAssert(internalSearch.tracker.buffer.volatileParameters[2].value() == "1", "La valeur du troisième paramètre doit être 1")
    }
    
    func testAddInternalSearchNoPosition() {
        internalSearches.tracker = internalSearch.tracker
        internalSearch = internalSearches.add("watch", resultScreenNumber: 3)
        
        XCTAssert(internalSearch.tracker.businessObjects.count == 1, "Le nombre d'objet en attente doit être égale à 1")
        
        XCTAssert(internalSearch.keyword == "watch", "le keyword de la recherche doit être égal à watch")
        XCTAssert((internalSearch.tracker.businessObjects[internalSearch.id] as! InternalSearch).keyword == "watch", "le keyword de la recherche doit être égal à watch")
        
        XCTAssert(internalSearch.resultScreenNumber == 3, "le numéro de page de la recherche doit être égal à 3")
        XCTAssert((internalSearch.tracker.businessObjects[internalSearch.id] as! InternalSearch).resultScreenNumber == 3, "le numéro de page de la recherche doit être égal à 3")
    }
    
    func testAddInternalSearchPosition() {
        internalSearches.tracker = internalSearch.tracker
        internalSearch = internalSearches.add("watch", resultScreenNumber: 3, resultPosition: 1)
        
        XCTAssert(internalSearch.tracker.businessObjects.count == 1, "Le nombre d'objet en attente doit être égale à 1")
        
        XCTAssert(internalSearch.keyword == "watch", "le keyword de la recherche doit être égal à watch")
        XCTAssert((internalSearch.tracker.businessObjects[internalSearch.id] as! InternalSearch).keyword == "watch", "le keyword de la recherche doit être égal à watch")
        
        XCTAssert(internalSearch.resultScreenNumber == 3, "le numéro de page de la recherche doit être égal à 3")
        XCTAssert((internalSearch.tracker.businessObjects[internalSearch.id] as! InternalSearch).resultScreenNumber == 3, "le numéro de page de la recherche doit être égal à 3")
        
        XCTAssert(internalSearch.resultPosition == 1, "le numéro de position de la recherche doit être égal à 1")
        XCTAssert((internalSearch.tracker.businessObjects[internalSearch.id] as! InternalSearch).resultPosition == 1, "le numéro de position de la recherche doit être égal à 1")
    }

}
