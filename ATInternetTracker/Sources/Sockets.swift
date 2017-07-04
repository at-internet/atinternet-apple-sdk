import Foundation
#if COCOAPODS
import SocketIO
#endif

protocol Sockets {
    func send(data: String)
    func isConnected() -> Bool
    func open()
    func close()
}

class SocketFactory {
    let liveManager: LiveNetworkManager
    let URL: String
    let token: String
    
    init(liveManager: LiveNetworkManager, URL: String, token: String) {
        self.liveManager = liveManager
        self.URL = URL
        self.token = token
    }
    
    func createSocket(name: String) -> Sockets {
        if name == "socket.io" {
            return SocketIOImpl(liveManager: self.liveManager, URL: self.URL, token: token)
        }
        assert(false, "accepted values : [socket.io | ]")
        return SocketIOImpl(liveManager: self.liveManager, URL: self.URL, token: token)
    }
}

class SocketIOImpl: Sockets {
    let socket: SocketIOClient
    let liveManager: LiveNetworkManager
    let token: String
    
    init(liveManager: LiveNetworkManager, URL: String, token: String) {
        self.liveManager = liveManager
        self.token = token
        self.socket = SocketIOClient(socketURL: Foundation.URL(string: SmartTrackerConfiguration.sharedInstance.ebsEndpoint)!,
                                    config: [.path("/smartsdk/socket.io"), .forceWebsockets(true), .log(false), .connectParams(["token": self.token])])
        
        socket.on("ScreenshotRequest", callback: socketHandler)
        socket.on("InterfaceAskedForLive", callback: socketHandler)
        socket.on("InterfaceAcceptedLive", callback: socketHandler)
        socket.on("InterfaceRefusedLive", callback: socketHandler)
        socket.on("InterfaceStoppedLive", callback: socketHandler)
        socket.on("InterfaceAbortedLiveRequest", callback: socketHandler)
        socket.on("InterfaceAskedForScreenshot", callback: socketHandler)
    }
    
    func isConnected() -> Bool {
        return socket.status == .connected
    }
    
    func send(data: String) {
        socket.emit("message", data)
    }
    
    func open() {
        socket.connect()
    }
    
    func close() {
        self.socket.disconnect()
    }
    
    func socketHandler(event: [Any], socket: SocketAckEmitter) -> () {
        let data = ATJSON(event)
        let eventType = data[0]["event"].string
        let content = data[0]["data"]
        let socketEvent = SocketEventFactory.create(eventType!, liveManager: self.liveManager, messageData: content)
        socketEvent.process()
    }
}

