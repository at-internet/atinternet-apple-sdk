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
//  BackgroundTaskManager.swift
//  Tracker
//

#if !os(watchOS)

import Foundation
#if canImport(UIKit)
import UIKit
#endif

/// Background task
public class BackgroundTask: NSObject {
    struct Static {
        static var instance: BackgroundTask?
        static var token: Int = 0
    }
    
    fileprivate static var __once: () = {
        Static.instance = BackgroundTask()
    }()
    
    typealias completionBlock = () -> Void
    
    /// Number of running tasks
    lazy var taskCounter: Int = 0
    /// Array of tasks identifiers
    lazy var tasks = [Int: Int]()
    /// Array of tasks completion block
    lazy var tasksCompletionBlocks = [Int: completionBlock]()
    /// A lock to protect access to the task counter from multiple threads.
    private var taskCounterLock = NSLock()
    /// A recursive lock to protect access to the tasks array from multiple threads.
    private var tasksLock = NSRecursiveLock()
    
    /**
     Private initializer (cannot instantiate BackgroundTaskManager)
     */
    fileprivate override init() {
        
    }
    
    /// BackgroundTaskManager singleton
    class var sharedInstance: BackgroundTask {
        _ = BackgroundTask.__once
        
        return Static.instance!
    }
    
    /**
     Starts a background task
     */
    func begin() -> Int {
        return begin(nil)
    }
    
    /// Starts a background and call the callback function when done
    ///
    /// - Parameter completion: completion block to call right before task ends
    /// - Returns: the taskKey
    func begin(_ completion: (() -> Void)!) -> Int {
        var taskKey = 0
        
        self.taskCounterLock.lock()
        taskKey = taskCounter
        taskCounter += 1
        self.taskCounterLock.unlock()
        
        #if canImport(UIKit) && !AT_EXTENSION
        let identifier = UIApplication.shared.beginBackgroundTask(expirationHandler: {
            self.end(taskKey)
        })
        tasks[taskKey] = identifier.rawValue
        
        if(completion != nil) {
            tasksCompletionBlocks[taskKey] = completion
        }
        
        return taskKey
        #else
            return -1
        #endif
    }
    
    /// Force task to end
    ///
    /// - Parameter key: ID of the task to end
    func end(_ key: Int) {
        self.tasksLock.lock()
        defer {
            self.tasksLock.unlock()
        }
        
        if let completionBlock = tasksCompletionBlocks[key] {
            completionBlock()
            tasksCompletionBlocks.removeValue(forKey: key)
        }
        
        if let taskId = tasks[key] {
            // On stoppe tous les envoi de hits offline en cours si le délais en background est expiré
            for operation in TrackerQueue.sharedInstance.queue.operations {
                if let sender = operation as? Sender {
                    if(!sender.isExecuting && sender.hit.isOffline) {
                        sender.cancel()
                    }
                }
            }
            
            #if canImport(UIKit) && !AT_EXTENSION
            // On arrete la tache en arrière plan
            UIApplication.shared.endBackgroundTask(UIBackgroundTaskIdentifier(rawValue: taskId))
            
            tasks[key] = UIBackgroundTaskIdentifier.invalid.rawValue
            tasks.removeValue(forKey: key)
            #endif
        }
    }
}

#endif
