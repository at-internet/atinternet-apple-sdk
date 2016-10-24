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
import CoreData

#if !AT_EXTENSION && !os(watchOS)
import UIKit
#endif

/// Hit sender
class Sender: NSOperation {
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
    func send(includeOfflineHit: Bool = true) {
        if(includeOfflineHit) {
            Sender.sendOfflineHits(self.tracker, forceSendOfflineHits: false, async: false)
        }
        
        self.sendWithCompletionHandler(nil)
    }
    
    /**
    Sends hit and call a callback to indicate if the hit was sent successfully or not
    
    - parameter a: callback to indicate whether hit was sent successfully or not
    */
    func sendWithCompletionHandler(completionHandler: ((success: Bool) -> Void)!) {
        let db = Storage.sharedInstance
        
        // Si pas de connexion ou que le mode offline est à "always"
        if((self.tracker.configuration.parameters["storage"] == "always" && !self.forceSendOfflineHits)
            || TechnicalContext.connectionType == TechnicalContext.ConnexionType.offline
            || (!hit.isOffline && db.count() > 0)) {
                // Si le mode offline n'est pas sur never (pas d'enregistrement)
                if(self.tracker.configuration.parameters["storage"] != "never") {
                    // Si le hit ne provient pas du stockage offline, on le sauvegarde
                    if(!hit.isOffline) {
                        if(db.insert(&hit.url, mhOlt: self.mhOlt)) {
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
            let URL = NSURL(string: hit.url)
            
            if let optURL = URL {
                // Si l'opération n'a pas été annulée on envoi sinon on sauvegarde le hit
                if(!cancelled) {
                    let semaphore = dispatch_semaphore_create(0)
                    
                    let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
                    sessionConfig.requestCachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData
                    let session = NSURLSession(configuration: sessionConfig)
                    let request = NSMutableURLRequest(URL: optURL, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData, timeoutInterval: 30)
                    
                    request.networkServiceType = NSURLRequestNetworkServiceType.NetworkServiceTypeBackground
                    
                    let task = session.dataTaskWithRequest(request, completionHandler: {(data, response, error) in
                        var statusCode: Int?
                        
                        if (response is NSHTTPURLResponse) {
                            let res = response as! NSHTTPURLResponse
                            statusCode = res.statusCode;
                        }
                        
                        // Le hit n'a pas pu être envoyé
                        if(data == nil || error != nil || statusCode != 200) {
                            // Si le hit ne provient pas du stockage offline, on le sauvegarde si le mode offline est différent de "never"
                            if(self.tracker.configuration.parameters["storage"] != "never") {
                                if(!self.hit.isOffline) {
                                    if(db.insert(&self.hit.url, mhOlt: self.mhOlt)) {
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
                                    let retryCount = db.getRetryCountForHit(self.hit.url)
                                    if(retryCount < self.retryCount) {
                                        db.setRetryCount(retryCount+1, hit: self.hit.url)
                                    } else {
                                        db.delete(self.hit.url)
                                    }
                                }
                                
                                var errorMessage = ""
                                
                                if let optError = error {
                                    errorMessage = optError.description
                                }
                                
                                // On lève une erreur indiquant qu'une réponse autre que 200 a été reçue
                                self.tracker.delegate?.sendDidEnd?(HitStatus.Failed, message: errorMessage)
                                
                                #if os(iOS) && !AT_EXTENSION
                                if(self.tracker.enableDebugger) {
                                    Debugger.sharedInstance.addEvent(errorMessage, icon: "error48")
                                }
                                #endif
                                
                                if((completionHandler) != nil) {
                                    completionHandler(success: false)
                                }
                            }
                        } else {
                            // Si le hit provient du stockage et que l'envoi a réussi, on le supprime de la base
                            if(self.hit.isOffline) {
                                OfflineHit.sentWithSuccess = true
                                db.delete(self.hit.url)
                            }
                            
                            self.tracker.delegate?.sendDidEnd?(HitStatus.Success, message: self.hit.url)
                            
                            #if os(iOS) && !AT_EXTENSION
                            if(self.tracker.enableDebugger) {
                                Debugger.sharedInstance.addEvent(self.hit.url, icon: "sent48")
                            }
                            #endif
                            if((completionHandler) != nil) {
                                completionHandler(success: true)
                            }
                        }
                        
                        session.finishTasksAndInvalidate()
                        
                        dispatch_semaphore_signal(semaphore)
                    })
                    
                    task.resume()
                    
                    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
                } else {
                    if(!hit.isOffline) {
                        if(db.insert(&hit.url, mhOlt: self.mhOlt)) {
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
                self.tracker.delegate?.sendDidEnd?(HitStatus.Failed, message: "Hit could not be parsed and sent")
                
                #if os(iOS) && !AT_EXTENSION
                if(self.tracker.enableDebugger) {
                    Debugger.sharedInstance.addEvent("Hit could not be parsed and sent : " + hit.url, icon: "error48")
                }
                #endif
                
                if((completionHandler) != nil) {
                    completionHandler(success: false)
                }
            }
        }
    }
    
    class func sendOfflineHits(tracker: Tracker, forceSendOfflineHits: Bool, async: Bool = true) {
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
                    if(offlineOperations.count == 0) {
                        let storage = Storage.sharedInstance
                        
                        // Check if offline hits exists in database
                        if(storage.count() > 0) {
                            
                            #if !AT_EXTENSION && !os(watchOS)
                            // Creates background task for offline hits
                            if(UIDevice.currentDevice().multitaskingSupported && tracker.configuration.parameters["enableBackgroundTask"]?.lowercaseString == "true") {
                                BackgroundTask.sharedInstance.begin()
                            }
                            #endif
                            
                            if(async) {
                                for offlineHit in storage.get() {
                                    let sender = Sender(tracker: tracker, hit: offlineHit, forceSendOfflineHits: forceSendOfflineHits, mhOlt: nil)
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
                            }
                        }
                    }
                }
                
        }
    }
}
