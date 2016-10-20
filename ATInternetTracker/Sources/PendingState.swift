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
class PendingState: LiveNetworkState {
    
    let liveManager: LiveNetworkManager
    init(liveManager: LiveNetworkManager) {
        self.liveManager = liveManager
    }
    
    func deviceAskedForLive() {}
    func interfaceAskedForLive() {
        // special patch: interface and device made a request, making "deadlock"
        let isAsking: Bool? = self.liveManager.sender?.timer?.isValid
        if isAsking ?? false {
            liveManager.sender?.stopAskingForLive()
            liveManager.toolbar?.pendingToConnected()
            liveManager.current = liveManager.connected
            liveManager.networkStatus = .Connected
            self.liveManager.sender?.sendMessageForce(DeviceAcceptedLive().description)
            liveManager.sender?.sendAll()
        }
    }
    
    func deviceAbortedLiveRequest(){
        liveManager.toolbar?.pendingToDisconnected()
        liveManager.networkStatus = .Disconnected
        liveManager.current = liveManager.disconnected
        liveManager.sender?.stopAskingForLive()
        liveManager.sender?.sendMessageForce(DeviceAbortedLiveRequest().description)
    }
    
    func deviceRefusedLive() {
        liveManager.toolbar?.pendingToDisconnected()
        liveManager.networkStatus = .Disconnected
        liveManager.current = liveManager.disconnected
        liveManager.autoReject = Date()
        self.liveManager.sender?.sendMessageForce(DeviceRefusedLive().description)
    }
    
    func deviceAcceptedLive() {
        liveManager.toolbar?.pendingToConnected()
        liveManager.current = liveManager.connected
        liveManager.networkStatus = .Connected
        self.liveManager.sender?.sendMessageForce(DeviceAcceptedLive().description)
        liveManager.sender?.sendBuffer()
        liveManager.sender?.sendAll()
    }
    
    func interfaceAcceptedLive() {
        liveManager.toolbar?.pendingToConnected()
        liveManager.current = liveManager.connected
        liveManager.networkStatus = .Connected
        liveManager.sender?.stopAskingForLive()
        liveManager.sender?.sendBuffer()
        self.liveManager.sender?.sendAll()
    }
    func interfaceRefusedLive(){
        liveManager.toolbar?.pendingToDisconnected()
        liveManager.networkStatus = .Disconnected
        liveManager.current = liveManager.disconnected
        liveManager.sender?.stopAskingForLive()
        liveManager.showRefusedPopup()
    }
    
    func deviceStoppedLive() { }
    
    func interfaceAbortedLiveRequest() {
        liveManager.toolbar?.pendingToDisconnected()
        liveManager.networkStatus = .Disconnected
        liveManager.current = liveManager.disconnected
        liveManager.currentPopupDisplayed?.dismiss(true)
        liveManager.showAbortedPopup()
    }
    
    func interfaceStoppedLive() {}
}
