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
import UIKit

/// Class for managing an NSOperationQueue
/// The Queue is a serial background queue that manage ScreenEvents and pass it to the Sender
class EventManager {
    /// Singleton
    static let sharedInstance = EventManager()
    
    /// delegate for test purpose (and more ?)
    //var delegate: EventHandler?

    /// Queue for managing events
    lazy fileprivate var _eventQueue:OperationQueue = OperationQueue()
    
    fileprivate init() {
        _eventQueue.maxConcurrentOperationCount = 1
        _eventQueue.name = "at_eventQueue"
        _eventQueue.qualityOfService = QualityOfService.background
    }
    
    /**
     addEvent : add an event to the queue
     
     - parameter event: An event to be added to queue to be sent to socket server
     */
    func addEvent(_ event: Operation) {
        _eventQueue.addOperation(event)
    }
    
    /**
     lastEvent : Get the last event in queue
     */
    func lastEvent() -> Operation? {
        return _eventQueue.operations.last
    }
    
    /**
     lastScreenEvent : Get the last screen event in queue
     */
    func lastScreenEvent() -> Operation? {
        for op in _eventQueue.operations.reversed() {
            if op is ScreenOperation {
                return op
            }
        }
        
        return nil
    }
    
    /**
     lastGestureEvent : Get the last gesture event in queue
     */
    func lastGestureEvent() -> Operation? {
        for op in _eventQueue.operations.reversed() {
            if op is GestureOperation {
                return op
            }
        }
        
        return nil
    }
    
    /**
     Only the screen event must be removed
     */
    func cancelLastScreenEvent() {
        let op = _eventQueue.operations.last
        if op is ScreenOperation {
            op?.cancel()
        }
    }
    
    /**
     cancelLastEvent : cancel the last event in queue
     */
    func cancelLastEvent() {
        _eventQueue.operations.last?.cancel()
    }
    
    /**
     For tests pupose (for now)
     */
    func cancelAllEvents() {
        _eventQueue.cancelAllOperations()
    }
}
