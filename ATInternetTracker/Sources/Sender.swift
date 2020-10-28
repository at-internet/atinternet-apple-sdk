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
//  Sender.swift
//  Tracker
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif

/// Hit sender
class Sender: Operation {
    /// Tracker instance
    let tracker: Tracker
    /// Hit to send
    var hit: Hit
    /// Number of retry
    let retryCount: Int = 3
    /// Olt fixed value to use if multihits
    var mhOlt: String?
    /// force offline hits to be sent
    var forceSendOfflineHits: Bool
    /// Static var to check whether offline hits are being sent or not
    struct OfflineHit {
        static var processing: Bool = false
        static var sentWithSuccess: Bool = false
    }
    
    /**
    Initialize a sender
    
    :params: tracker instance
    :params: hit to send
    :params: isOfflineHit indicates whether hit comes from database or not
    */
    init(tracker: Tracker, hit: Hit, forceSendOfflineHits: Bool, mhOlt: String?) {
        self.tracker = tracker
        self.hit = hit
        self.forceSendOfflineHits = forceSendOfflineHits
        self.mhOlt = mhOlt
    }
    
    /**
    Main function of NSOperation
    */
    override func main () {
        autoreleasepool{
            self.send(false)
        }
    }
    
    /**
    Sends hit
    */
    func send(_ includeOfflineHit: Bool = true) {
        if(includeOfflineHit) {
            Sender.sendOfflineHits(self.tracker, forceSendOfflineHits: false, async: false)
        }
        
        self.sendWithCompletionHandler(nil)
    }
    
    /**
    Sends hit and call a callback to indicate if the hit was sent successfully or not
    
    - parameter a: callback to indicate whether hit was sent successfully or not
    */
    func sendWithCompletionHandler(_ completionHandler: ((_ success: Bool) -> Void)?) {
        // Don't send hits if the app is in state not allowed to send

        /// app is in inactive state
        if TechnicalContext.applicationState == .inactive && tracker.sendOnApplicationState == SendApplicationState.activeOnly {
            completionHandler?(false)
            return
        }
        
        /// app is in background state
        if TechnicalContext.applicationState == .background && tracker.sendOnApplicationState != SendApplicationState.all {
            completionHandler?(false)
            return
        }
        
        let db = Storage.sharedInstanceOf(self.tracker.configuration.parameters["storage"] ?? "never", forceStorageAccess: self.forceSendOfflineHits)
        
        // Si pas de connexion ou que le mode offline est à "always"
        if((self.tracker.configuration.parameters["storage"] == "always" && !self.forceSendOfflineHits)
            || TechnicalContext.connectionType == TechnicalContext.ConnexionType.offline
            || (!hit.isOffline && db.count() > 0)) {
                // Si le mode offline n'est pas sur never (pas d'enregistrement)
                if(self.tracker.configuration.parameters["storage"] != "never") {
                    // Si le hit ne provient pas du stockage offline, on le sauvegarde
                    if(!hit.isOffline) {
                        if(db.insert(&hit.url, hitId: self.hit.id, mhOlt: self.mhOlt)) {
                            self.tracker.delegate?.saveDidEnd?(hit.url)
                            
                            #if os(iOS) && !AT_EXTENSION
                            if(self.tracker.enableDebugger) {
                                Debugger.sharedInstance.addEvent(self.hit.url, icon: "save48")
                            }
                            #endif
                        } else {
                            self.tracker.delegate?.warningDidOccur?("Hit could not be saved : " + hit.url)
                            
                            #if os(iOS) && !AT_EXTENSION
                            if(self.tracker.enableDebugger) {
                                Debugger.sharedInstance.addEvent("Hit could not be saved : " + hit.url, icon: "warning48")
                            }
                            #endif
                        }
                    }
                }
        } else {
            let URL = Foundation.URL(string: hit.url)
            
            if let optURL = URL {
                // Si l'opération n'a pas été annulée on envoi sinon on sauvegarde le hit
                if(!isCancelled) {
                    let semaphore = DispatchSemaphore(value: 0)
                    
                    let sessionConfig = URLSessionConfiguration.default                    
                    sessionConfig.requestCachePolicy = NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData
                    let session = URLSession(configuration: sessionConfig)
                    var request = URLRequest(url: optURL, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData, timeoutInterval: 30)
                    request.networkServiceType = NSURLRequest.NetworkServiceType.background
                    
                    if self.tracker.userAgent != "" {
                        request.setValue(self.tracker.userAgent, forHTTPHeaderField: "User-Agent")
                    } else if let optDefaultUa = TechnicalContext.defaultUserAgent {
                        request.setValue(optDefaultUa, forHTTPHeaderField: "User-Agent")
                    }
                    
                    let task = session.dataTask(with: request, completionHandler: {(data, response, error) in
                        var statusCode: Int?
                        
                        if (response is HTTPURLResponse) {
                            let res = response as! HTTPURLResponse
                            statusCode = res.statusCode;
                        }
                        
                        // Le hit n'a pas pu être envoyé
                        if(data == nil || error != nil || statusCode != 200) {
                            // Si le hit ne provient pas du stockage offline, on le sauvegarde si le mode offline est différent de "never"
                            if(self.tracker.configuration.parameters["storage"] != "never") {
                                if(!self.hit.isOffline) {
                                    if(db.insert(&self.hit.url, hitId: self.hit.id, mhOlt: self.mhOlt)) {
                                        self.tracker.delegate?.saveDidEnd?(self.hit.url)
                                        
                                        #if os(iOS) && !AT_EXTENSION
                                        if(self.tracker.enableDebugger) {
                                            Debugger.sharedInstance.addEvent(self.hit.url, icon: "save48")
                                        }
                                        #endif
                                    } else {
                                        self.tracker.delegate?.warningDidOccur?("Hit could not be saved : " + self.hit.url)
                                        
                                        #if os(iOS) && !AT_EXTENSION
                                        if(self.tracker.enableDebugger) {
                                            Debugger.sharedInstance.addEvent("Hit could not be saved : " + self.hit.url, icon: "warning48")
                                        }
                                        #endif
                                    }
                                } else {
                                    let retryCount = db.getRetryCountForHit(self.hit.id)
                                    if(retryCount < self.retryCount) {
                                        db.setRetryCount(retryCount+1, hitId: self.hit.id)
                                    } else {
                                        _ = db.delete(self.hit.id)
                                    }
                                }
                                
                                var errorMessage = ""
                                
                                if let optError = error {
                                    errorMessage = optError.localizedDescription
                                }
                                
                                // On lève une erreur indiquant qu'une réponse autre que 200 a été reçue
                                self.tracker.delegate?.sendDidEnd?(HitStatus.failed, message: errorMessage)
                                
                                #if os(iOS) && !AT_EXTENSION
                                if(self.tracker.enableDebugger) {
                                    Debugger.sharedInstance.addEvent(errorMessage, icon: "error48")
                                }
                                #endif
                                
                                completionHandler?(false)
                            }
                        } else {
                            // Si le hit provient du stockage et que l'envoi a réussi, on le supprime de la base
                            if(self.hit.isOffline) {
                                OfflineHit.sentWithSuccess = true
                                _ = db.delete(self.hit.url)
                            }
                            
                            self.tracker.delegate?.sendDidEnd?(HitStatus.success, message: self.hit.url)
                            
                            #if os(iOS) && !AT_EXTENSION
                            if(self.tracker.enableDebugger) {
                                Debugger.sharedInstance.addEvent(self.hit.url, icon: "sent48")
                            }
                            #endif
                            
                            completionHandler?(true)
                        }
                        
                        session.finishTasksAndInvalidate()
                        
                        semaphore.signal()
                    })
                    
                    task.resume()
                    
                    _ = semaphore.wait(timeout: DispatchTime.distantFuture)
                } else {
                    if(!hit.isOffline) {
                        if(db.insert(&hit.url, hitId: self.hit.id, mhOlt: self.mhOlt)) {
                            self.tracker.delegate?.saveDidEnd?(hit.url)
                            
                            #if os(iOS) && !AT_EXTENSION
                            if(self.tracker.enableDebugger) {
                                Debugger.sharedInstance.addEvent(self.hit.url, icon: "save48")
                            }
                            #endif
                        } else {
                            self.tracker.delegate?.warningDidOccur?("Hit could not be saved : " + hit.url)
                            
                            #if os(iOS) && !AT_EXTENSION
                            if(self.tracker.enableDebugger) {
                                Debugger.sharedInstance.addEvent("Hit could not be saved : " + hit.url, icon: "warning48")
                            }
                            #endif
                        }
                    }
                }
                
            } else  {
                //On lève une erreur indiquant que le hit n'a pas été correctement construit et n'a pas pu être envoyé
                self.tracker.delegate?.sendDidEnd?(HitStatus.failed, message: "Hit could not be parsed and sent")
                
                #if os(iOS) && !AT_EXTENSION
                if(self.tracker.enableDebugger) {
                    Debugger.sharedInstance.addEvent("Hit could not be parsed and sent : " + hit.url, icon: "error48")
                }
                #endif

                completionHandler?(false)
            }
        }
    }
    
    class func sendOfflineHits(_ tracker: Tracker, forceSendOfflineHits: Bool, async: Bool = true) {
        if((tracker.configuration.parameters["storage"] != "always" || forceSendOfflineHits)
            && TechnicalContext.connectionType != TechnicalContext.ConnexionType.offline) {
                
                if(OfflineHit.processing == false)
                {
                    // Check whether offline hits are already being sent
                    let offlineOperations = TrackerQueue.sharedInstance.queue.operations.filter() {
                        if let sender = $0 as? Sender {
                            if(sender.hit.isOffline == true) {
                                return true
                            } else {
                                return false
                            }
                        }
                        
                        return false
                    }
                    
                    // If there's no offline hit being sent
                    if offlineOperations.count == 0 {
                        let storage = Storage.sharedInstanceOf(tracker.configuration.parameters["storage"] ?? "never", forceStorageAccess: forceSendOfflineHits)
                        
                        // Check if offline hits exists in database
                        if storage.count() > 0 {
                            
                            let backgroundTaskIdentifier: Int?
                            
                            #if !(AT_EXTENSION || os(watchOS)) && canImport(UIKit)
                            // Creates background task for offline hits
                            if UIDevice.current.isMultitaskingSupported && tracker.backgroundTaskEnabled {
                                backgroundTaskIdentifier = BackgroundTask.sharedInstance.begin()
                            } else {
                                backgroundTaskIdentifier = nil
                            }
                            #else
                                backgroundTaskIdentifier = nil
                            #endif
                            
                            #if !(AT_EXTENSION || os(watchOS))
                            if(async) {
                                for offlineHit in storage.get() {
                                    let sender = Sender(tracker: tracker, hit: offlineHit, forceSendOfflineHits: forceSendOfflineHits, mhOlt: nil)
                                    sender.completionBlock = {
                                        guard let backgroundTaskIdentifier = backgroundTaskIdentifier else { return }
                                        BackgroundTask.sharedInstance.end(backgroundTaskIdentifier)
                                    }
                                    TrackerQueue.sharedInstance.queue.addOperation(sender)
                                }
                            } else {
                                OfflineHit.processing = true
                                
                                for offlineHit in storage.get() {
                                    OfflineHit.sentWithSuccess = false
                                    let sender = Sender(tracker: tracker, hit: offlineHit, forceSendOfflineHits: forceSendOfflineHits, mhOlt: nil)
                                    sender.send(false)
                                    
                                    if(!OfflineHit.sentWithSuccess) {
                                        break
                                    }
                                    
                                }
                                
                                OfflineHit.processing = false
                                
                                if let backgroundTaskIdentifier = backgroundTaskIdentifier {
                                    BackgroundTask.sharedInstance.end(backgroundTaskIdentifier)
                                }
                            }
                            #endif
                        }
                    }
                }
                
        }
    }
}

extension Tracker {
    var backgroundTaskEnabled: Bool {
        guard let enableBackgroundTask = configuration.parameters["enableBackgroundTask"]
            else { return false }
        
        return enableBackgroundTask.lowercased() == "true"
    }
    var sendOnApplicationState: SendApplicationState {
        guard let sendOnApplicationState = configuration.parameters["sendOnApplicationState"]
            else { return SendApplicationState.all }
        
        switch sendOnApplicationState {
            case "activeOnly":
                return SendApplicationState.activeOnly
            case "activeOrInactive":
                return SendApplicationState.activeOrInactive
            default:
                return SendApplicationState.all
        }
    }
}
