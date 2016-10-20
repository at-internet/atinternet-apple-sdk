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
import CoreGraphics

protocol LiveNetworkState {
    func deviceAskedForLive()
    func interfaceAskedForLive()
    
    func interfaceAbortedLiveRequest()
    func deviceAbortedLiveRequest()
    
    func deviceRefusedLive()
    func interfaceRefusedLive()
    
    func deviceAcceptedLive()
    func interfaceAcceptedLive()
    
    func deviceStoppedLive()
    func interfaceStoppedLive()
}

class LiveNetworkManager: LiveNetworkState {
    enum NetworkStatus: String {
        case Connected = "Connected"
        case Disconnected = "Disconnected"
        case Pending = "Pending"
    }
    
    lazy var disconnected: LiveNetworkState = DisconnectedState(liveManager: self)
    lazy var connected : LiveNetworkState = ConnectState(liveManager: self)
    lazy var pending: LiveNetworkState = PendingState(liveManager: self)
    var current: LiveNetworkState?
    var networkStatus: NetworkStatus = .Disconnected
    var currentPopupDisplayed: KLCPopup?
    var autoReject: Date?
    let COOLDOWN = 3.0
    
    var sender: SocketSender?
    var toolbar: SmartToolBarController?
    
    init(sender: SocketSender, toobar: SmartToolBarController) {
        self.sender = sender
        self.toolbar = toobar
    }
    
    init() {
        self.sender = nil
        self.toolbar = nil
    }
    
    func initState() {
        current = disconnected
    }
    
    func deviceAskedForLive() {
        current?.deviceAskedForLive()
    }
    func interfaceAskedForLive() {
        current?.interfaceAskedForLive()
    }
    
    func deviceRefusedLive() {
        current?.deviceRefusedLive()
    }
    func interfaceRefusedLive(){
        current?.interfaceRefusedLive()
    }
    
    func deviceAcceptedLive() {
        current?.deviceAcceptedLive()
    }
    func interfaceAcceptedLive() {
        current?.interfaceAcceptedLive()
    }
    
    func deviceStoppedLive() {
        current?.deviceStoppedLive()
    }
    func interfaceStoppedLive() {
        current?.interfaceStoppedLive()
    }
    func deviceAbortedLiveRequest(){
        current?.deviceAbortedLiveRequest()
    }
    func interfaceAbortedLiveRequest(){
        current?.interfaceAbortedLiveRequest()
    }
    
    func showPairingPopup() {
        self.currentPopupDisplayed?.dismiss(true)
        let texts = getTexts()
        let p = SmartPopUp(frame: CGRect.zero, title: texts["ASK_PAIRING_TITLE"]!, message: texts["ASK_PAIRING_TEXT"]!, okTitle: texts["CONFIRM"]!, cancelTitle: texts["CANCEL"]!)
        self.currentPopupDisplayed = KLCPopup(contentView: p,
                             showType: KLCPopupShowType.bounceInFromTop,
                             dismissType: KLCPopupDismissType.bounceOutToBottom,
                             maskType: KLCPopupMaskType.dimmed,
                             dismissOnBackgroundTouch: false,
                             dismissOnContentTouch: false)
        p.addOkAction { () -> () in
            self.deviceAcceptedLive()
            self.currentPopupDisplayed!.dismiss(true)
        }
        p.addCancelAction { () -> () in
            self.deviceRefusedLive()
            self.currentPopupDisplayed!.dismiss(true)
        }
        
        self.currentPopupDisplayed!.show()
    }
    
    
    
    func showAbortedPopup() {
        let texts = getTexts()
        self.currentPopupDisplayed?.dismiss(true)
        let p = SmartPopUp(frame: CGRect.zero, title: texts["INFO_PAIRING_CANCELED_TITLE"]!, message: texts["INFO_PAIRING_CANCELED_TEXT"]!, okTitle: texts["CONFIRM"]!)
        self.currentPopupDisplayed = KLCPopup(contentView: p,
                             showType: KLCPopupShowType.bounceInFromTop,
                             dismissType: KLCPopupDismissType.bounceOutToBottom,
                             maskType: KLCPopupMaskType.dimmed,
                             dismissOnBackgroundTouch: false,
                             dismissOnContentTouch: false)
        p.addOkAction { () -> () in
            self.currentPopupDisplayed!.dismiss(true)
        }
        
        self.currentPopupDisplayed!.show()
    }
    
    func showStoppedPopup() {
        let texts = getTexts()
        self.currentPopupDisplayed?.dismiss(true)
        let p = SmartPopUp(frame: CGRect.zero, title: texts["INFO_PAIRING_STOPPED_TITLE"]!, message: texts["INFO_PAIRING_STOPPED_TEXT"]!, okTitle: texts["CONFIRM"]!)
        self.currentPopupDisplayed = KLCPopup(contentView: p,
                             showType: KLCPopupShowType.bounceInFromTop,
                             dismissType: KLCPopupDismissType.bounceOutToBottom,
                             maskType: KLCPopupMaskType.dimmed,
                             dismissOnBackgroundTouch: false,
                             dismissOnContentTouch: false)
        p.addOkAction { () -> () in
            self.currentPopupDisplayed!.dismiss(true)
        }
        
        self.currentPopupDisplayed!.show()
    }
    
    func showRefusedPopup() {
        let texts = getTexts()
        self.currentPopupDisplayed?.dismiss(true)
        let p = SmartPopUp(frame: CGRect.zero, title: texts["INFO_PAIRING_REFUSED_TITLE"]!, message: texts["INFO_PAIRING_REFUSED_TEXT"]!, okTitle: texts["CONFIRM"]!)
        self.currentPopupDisplayed = KLCPopup(contentView: p,
                             showType: KLCPopupShowType.bounceInFromTop,
                             dismissType: KLCPopupDismissType.bounceOutToBottom,
                             maskType: KLCPopupMaskType.dimmed,
                             dismissOnBackgroundTouch: false,
                             dismissOnContentTouch: false)
        p.addOkAction { () -> () in
            self.currentPopupDisplayed!.dismiss(true)
        }

        self.currentPopupDisplayed!.show()
    }
    
    func getTexts() -> [String:String] {
        return [
            "ASK_PAIRING_TITLE": NSLocalizedString("ASK_PAIRING_TITLE", tableName: nil, bundle: Bundle(for: Tracker.self), value: "", comment: "titre"),
            "ASK_PAIRING_TEXT" : NSLocalizedString("ASK_PAIRING_TEXT", tableName: nil, bundle: Bundle(for: Tracker.self), value: "", comment: "content"),
            "CONFIRM": NSLocalizedString("CONFIRM", tableName: nil, bundle: Bundle(for: Tracker.self), value: "", comment: "content"),
            "CANCEL": NSLocalizedString("CANCEL", tableName: nil, bundle: Bundle(for: Tracker.self), value: "", comment: "content"),
            "INFO_PAIRING_CANCELED_TEXT": NSLocalizedString("INFO_PAIRING_CANCELED_TEXT", tableName: nil, bundle: Bundle(for: Tracker.self), value: "", comment: "content"),
            "INFO_PAIRING_CANCELED_TITLE": NSLocalizedString("INFO_PAIRING_CANCELED_TITLE", tableName: nil, bundle: Bundle(for: Tracker.self), value: "", comment: "titre"),
            "INFO_PAIRING_STOPPED_TITLE": NSLocalizedString("INFO_PAIRING_STOPPED_TITLE", tableName: nil, bundle: Bundle(for: Tracker.self), value: "", comment: "titre"),
            "INFO_PAIRING_STOPPED_TEXT": NSLocalizedString("INFO_PAIRING_STOPPED_TEXT", tableName: nil, bundle: Bundle(for: Tracker.self), value: "", comment: "content"),
            "INFO_PAIRING_REFUSED_TEXT": NSLocalizedString("INFO_PAIRING_REFUSED_TEXT", tableName: nil, bundle: Bundle(for: Tracker.self), value: "", comment: "content"),
            "INFO_PAIRING_REFUSED_TITLE": NSLocalizedString("INFO_PAIRING_REFUSED_TITLE", tableName: nil, bundle: Bundle(for: Tracker.self), value: "", comment: "titre")
        ]
    }
}
