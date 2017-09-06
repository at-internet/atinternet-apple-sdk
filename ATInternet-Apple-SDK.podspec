Pod::Spec.new do |s|
	s.name = "ATInternet-Apple-SDK"
	s.version = '2.6.1'
	s.summary = "AT Internet mobile analytics solution for Apple devices"
	s.homepage = "https://github.com/at-internet/atinternet-apple-sdk"
	s.documentation_url	= 'http://developers.atinternet-solutions.com/apple-en/getting-started-apple-en/operating-principle-apple-en/'
	s.license = "MIT"
	s.author = "AT Internet"
	s.requires_arc = true
	s.source = { :git => "https://github.com/at-internet/atinternet-apple-sdk.git", :tag => s.version}
	s.module_name = 'Tracker'
	s.ios.deployment_target	= '8.0'
	s.tvos.deployment_target = '9.0'
	s.watchos.deployment_target = '2.0'

	$external_dependencies = [
		"ATInternetTracker/Sources/JRSwizzle.h",
		"ATInternetTracker/Sources/JRSwizzle.m",
		"ATInternetTracker/Sources/KLCPopup.h",
		"ATInternetTracker/Sources/KLCPopup.m",
    "ATInternetTracker/Sources/SocketAckEmitter.swift",
    "ATInternetTracker/Sources/SocketAckManager.swift",
    "ATInternetTracker/Sources/SocketAnyEvent.swift",
    "ATInternetTracker/Sources/SocketClientManager.swift",
    "ATInternetTracker/Sources/SocketEngine.swift",
    "ATInternetTracker/Sources/SocketEngineClient.swift",
    "ATInternetTracker/Sources/SocketEnginePacketType.swift",
    "ATInternetTracker/Sources/SocketEnginePollable.swift",
    "ATInternetTracker/Sources/SocketEngineSpec.swift",
    "ATInternetTracker/Sources/SocketEngineWebsocket.swift",
    "ATInternetTracker/Sources/SocketEventHandler.swift",
    "ATInternetTracker/Sources/SocketExtensions.swift",
    "ATInternetTracker/Sources/SocketIOClient.swift",
    "ATInternetTracker/Sources/SocketIOClientConfiguration.swift",
    "ATInternetTracker/Sources/SocketIOClientOption.swift",
    "ATInternetTracker/Sources/SocketIOClientSpec.swift",
    "ATInternetTracker/Sources/SocketIOClientStatus.swift",
    "ATInternetTracker/Sources/SocketLogger.swift",
    "ATInternetTracker/Sources/SocketPacket.swift",
    "ATInternetTracker/Sources/SocketParsable.swift",
    "ATInternetTracker/Sources/SocketStringReader.swift",
    "ATInternetTracker/Sources/SocketTypes.swift",
    "ATInternetTracker/Sources/SSLSecurity.swift",
    "ATInternetTracker/Sources/WebSocket.swift",
	]
	$smart_sdk = [
		"ATInternetTracker/Sources/UIApplicationContext.swift",
		"ATInternetTracker/Sources/UIViewControllerContext.swift",
		"ATInternetTracker/Sources/SmartTrackerConfiguration.swift",
		"ATInternetTracker/Sources/EventManager.swift",
		"ATInternetTracker/Sources/GestureEvent.swift",
		"ATInternetTracker/Sources/GestureOperation.swift",
		"ATInternetTracker/Sources/PanEvent.swift",
		"ATInternetTracker/Sources/PinchEvent.swift",
		"ATInternetTracker/Sources/RefreshEvent.swift",
		"ATInternetTracker/Sources/RotationEvent.swift",
		"ATInternetTracker/Sources/ScreenEvent.swift",
		"ATInternetTracker/Sources/ScreenOperation.swift",
		"ATInternetTracker/Sources/ScreenRotationEvent.swift",
		"ATInternetTracker/Sources/ScreenRotationOperation.swift",
		"ATInternetTracker/Sources/DeviceRotationEvent.swift",
		"ATInternetTracker/Sources/ScreenshotEvent.swift",
		"ATInternetTracker/Sources/ScrollEvent.swift",
		"ATInternetTracker/Sources/SwipeEvent.swift",
		"ATInternetTracker/Sources/TapEvent.swift",
		"ATInternetTracker/Sources/ApiS3.swift",
		"ATInternetTracker/Sources/ConnectedState.swift",
		"ATInternetTracker/Sources/DisconnectedState.swift",
		"ATInternetTracker/Sources/LiveManager.swift",
		"ATInternetTracker/Sources/Messages.swift",
		"ATInternetTracker/Sources/PendingState.swift",
		"ATInternetTracker/Sources/SocketEvents.swift",
		"ATInternetTracker/Sources/SocketSender.swift",
		"ATInternetTracker/Sources/IgnoredViews.swift",
		"ATInternetTracker/Sources/SmartPopUp.swift",
		"ATInternetTracker/Sources/SmartToolbar.swift",
		"ATInternetTracker/Sources/NSObjectExtension.swift",
		"ATInternetTracker/Sources/UIApplicationExtension.swift",
		"ATInternetTracker/Sources/UIImageExtension.swift",
		"ATInternetTracker/Sources/UIRefreshControlExtension.swift",
		"ATInternetTracker/Sources/UISwitchExtension.swift",
		"ATInternetTracker/Sources/UIViewControllerExtension.swift",
		"ATInternetTracker/Sources/UIViewExtension.swift",
		"ATInternetTracker/Sources/*.ttf",
		"ATInternetTracker/Sources/App.swift",
		"ATInternetTracker/Sources/Rotator.swift",
		"ATInternetTracker/Sources/View.swift",
		"ATInternetTracker/Sources/ATGestureRecognizer.m",
		"ATInternetTracker/Sources/ATGestureRecognizer.h",
		"ATInternetTracker/Sources/SmartTracker.h",
		"ATInternetTracker/Sources/tvOSTracker.h",
		"ATInternetTracker/Sources/watchOSTracker.h",
		"ATInternetTracker/Sources/UILabelExtension.swift",
        "ATInternetTracker/Sources/EventFactory.swift",
        "ATInternetTracker/Sources/Sockets.swift"
	]

	s.subspec 'Tracker' do |tracker|
		tracker.source_files = "ATInternetTracker/Sources/*.{h,m,swift}"
		tracker.exclude_files = $smart_sdk + $external_dependencies
		tracker.resources = "ATInternetTracker/Sources/*.{plist,xcdatamodeld,png,json}", "ATInternetTracker/Sources/Images.xcassets"
		tracker.frameworks = "CoreData", "CoreFoundation", "UIKit", "CoreTelephony", "SystemConfiguration"
		tracker.platform = :ios
	end

	s.subspec 'AppExtension' do |appExt|
		appExt.pod_target_xcconfig	  = { 'OTHER_SWIFT_FLAGS' => '-DAT_EXTENSION' }
		appExt.source_files           = "ATInternetTracker/Sources/*.{h,m,swift}"
		appExt.exclude_files          = ["ATInternetTracker/Sources/BackgroundTask.swift","ATInternetTracker/Sources/Debugger.swift"] + $smart_sdk + $external_dependencies
		appExt.frameworks             = "CoreData", "CoreFoundation", "WatchKit", "UIKit", "SystemConfiguration", "CoreTelephony"
		appExt.platform				  = :ios
		appExt.resources = "ATInternetTracker/Sources/*.{plist,xcdatamodeld,png,json}", "ATInternetTracker/Sources/Images.xcassets"
	end

	s.subspec 'SmartTracker' do |st|
		st.source_files = "ATInternetTracker/Sources/*.{h,m,swift}"
		st.exclude_files = $external_dependencies
		st.resources = "ATInternetTracker/Sources/*.{plist,xcdatamodeld,png,json,mp3,ttf}", "ATInternetTracker/Sources/Images.xcassets", "ATInternetTracker/Sources/SmartSDK.xcassets","ATInternetTracker/Sources/en.lproj", "ATInternetTracker/Sources/fr.lproj"
		st.frameworks = "CoreData", "CoreFoundation", "UIKit", "CoreTelephony", "SystemConfiguration", "CFNetwork", "Security", "Foundation"
		st.platform	= :ios
		st.ios.deployment_target = '8.0'
		st.pod_target_xcconfig = { 'OTHER_SWIFT_FLAGS' => '-DAT_SMART_TRACKER' }
		st.libraries = "icucore"
		st.dependency 'JRSwizzle'
		st.dependency 'KLCPopup'
		st.dependency 'Socket.IO-Client-Swift'
	end

    s.subspec 'watchOSTracker' do |wos|
		wos.source_files           = "ATInternetTracker/Sources/*.{h,m,swift}"
		wos.exclude_files          = ["ATInternetTracker/Sources/BackgroundTask.swift","ATInternetTracker/Sources/ATReachability.swift","ATInternetTracker/Sources/Debugger.swift"] + $smart_sdk + $external_dependencies
		wos.frameworks             = "CoreData", "CoreFoundation", "WatchKit"
		wos.platform				  = :watchos
		wos.resources = "ATInternetTracker/Sources/DefaultConfiguration.plist","ATInternetTracker/Sources/core.manifest.json", "ATInternetTracker/Sources/*.xcdatamodeld"
	end

    s.subspec 'tvOSTracker' do |tvos|
		tvos.source_files = "ATInternetTracker/Sources/*.{h,m,swift}"
		tvos.exclude_files = $smart_sdk + $external_dependencies
		tvos.resources = "ATInternetTracker/Sources/*.{plist,xcdatamodeld,png,json,mp3,ttf}", "ATInternetTracker/Sources/Images.xcassets"
		tvos.frameworks = "CoreData", "CoreFoundation", "UIKit", "SystemConfiguration"
		tvos.platform = :tvos
	end
end
