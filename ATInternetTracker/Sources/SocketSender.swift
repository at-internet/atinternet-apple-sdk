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


/// Class reponsible for sending events
public class SocketSender {
    
    /// Websocket
    //var socket: SRWebSocket?
    var socket: Sockets?
    
    let serialQueue = DispatchQueue(label: "dsk_socketio")
    
    /// askforlive
    var timer: Timer?
    
    /// askforlive every RECONNECT_INTERVAL
    let RECONNECT_INTERVAL: Double = 2.0
    
    /// delegate to handle incoming msg
    //var socketHandler: SocketDelegate
    
    /// URL of the ws
    //let URL: String
    
    /// handler for the different scenarios of pairing
    let liveManager: LiveNetworkManager
    
    /// Buffer used to save the App and the current Screen displayed
    var buffer = EventBuffer()

    /**
     *  Buffer used to handle the App and the current screen displayed in case of reconnections
     *  note : The App can be different at different time (orientation)
     */
    struct EventBuffer {
        var currentScreen: String = ""
        var currentApp: String {
            return App().description
        }
    }
    
    /// queue managing events
    var queue:Array<String> = []
    
    /**
     init
     
     - parameter liveManager: a live manager
     - parameter token:       a valid token
     
     - returns: SocketSender (should be a single instance)
     */
    init(liveManager: LiveNetworkManager, token: String) {
        //self.URL = "ws://localhost:5000/"+token
        //self.URL = "ws://172.20.23.156:5000/" + token
        //self.URL = "ws://tag-smartsdk-dev.atinternet-solutions.com/" + token
        //let URL = SmartTrackerConfiguration.sharedInstance.ebsEndpoint + token
        self.liveManager = liveManager
        self.socket = SocketFactory(liveManager: liveManager, URL: SmartTrackerConfiguration.sharedInstance.ebsEndpoint, token: token).createSocket(name: "socket.io")
        //self.socketHandler = SocketDelegate(liveManager: liveManager)
    }
    
    /**
     open the socket
     */
    func open() {
        
        if isConnected() || ATInternet.sharedInstance.defaultTracker.enableLiveTagging == false {
            return
        }
        socket?.open()
    }
    
    /**
     Close socket
     */
    func close() {
        if isConnected() {
            socket?.close()
        }
    }
    
    /**
     check if the socket is connected
     
     - returns: the state of the connexion
     */
    fileprivate func isConnected() -> Bool {
        return (socket != nil) && socket!.isConnected()
    }
    
    func sendBuffer() {
        //assert(isConnected())
        //assert(self.liveManager.networkStatus == .Connected)
        socket?.send(data: buffer.currentApp)
        socket?.send(data: buffer.currentScreen)
    }
    
    /**
     send all events in the buffer list
     */
    func sendAll() {
        //assert(isConnected())
        //assert(self.liveManager.networkStatus == .Connected)
        serialQueue.sync {
            while queue.count > 0 {
                self.sendFirst()
            }
        }
    }
    
    /**
     send a JSON message to the server
     
     - parameter json: the message as a String (JSON formatted)
     */
    func sendMessage(_ json: String) {
        let eventName = ATJSON.parse(json)["event"].string
        // keep a ref to the last screen
        if eventName == "viewDidAppear" {
            buffer.currentScreen = json
            if self.liveManager.networkStatus == .Disconnected {
                return
            }
        }
        
        self.queue.append(json)
        if self.liveManager.networkStatus == .Connected {
            self.sendAll()
        }
    }
    
    /**
     Send a message even if not paired
     
     - parameter json: the message
     */
    func sendMessageForce(_ json: String) {
        if isConnected() {
            socket?.send(data: json)
        }
    }
    
    /**
     Ask for live with a timer so the pairing looks in real time
     */
    func startAskingForLive() {
        timer?.invalidate()
        timer = Timer(timeInterval: RECONNECT_INTERVAL, target: self, selector: #selector(SocketSender.sendAskingForLive), userInfo: nil, repeats: true)
        timer?.fire()
        RunLoop.main.add(timer!, forMode: RunLoopMode.commonModes)
    }
    
    /**
     AskForLive - we force it because not currently in live
     */
    @objc func sendAskingForLive() {
        sendMessageForce(DeviceAskingForLive().description)
    }
    
    /**
     Stop the askforlive timer
     */
    func stopAskingForLive() {
        timer?.invalidate()
    }
    
    /**
     Send the first message (act as a FIFO)
     */
    fileprivate func sendFirst() {
        let msg = queue.first
        if let message = msg {
            socket?.send(data: message)
            self.queue.remove(at: 0)
        }
    }
}

/**
 Possible message comming from the socketserver
 
 - Screenshot: A screenshot is requested (more below)
 */
enum SmartSocketEvent: String {
    /// Socket -> Device
    case Screenshot     = "ScreenshotRequest"
    /// Front -> Device
    case InterfaceAskedForLive  = "InterfaceAskedForLive"
    /// Front -> Device : live accepted
    case InterfaceAcceptedLive = "InterfaceAcceptedLive"
    /// Front -> Device : live refused
    case InterfaceRefusedLive = "InterfaceRefusedLive"
    /// Front -> Device
    case InterfaceAskedForScreenshot = "InterfaceAskedForScreenshot"
    /// Front -> Device : live stopped
    case InterfaceStoppedLive = "InterfaceStoppedLive"
    case InterfaceAbortedLiveRequest = "InterfaceAbortedLiveRequest"
}
