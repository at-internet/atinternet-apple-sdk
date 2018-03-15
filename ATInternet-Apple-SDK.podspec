$smart_sdk = File.readlines('smartsdk.txt').map(&:strip)
$external_dependencies = File.readlines('dependencies.txt').map(&:strip)

Pod::Spec.new do |s|
	s.name = "ATInternet-Apple-SDK"
	s.version = '2.8.9'
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
		appExt.exclude_files          = ["ATInternetTracker/Sources/BackgroundTask.swift","ATInternetTracker/Sources/Debugger.swift","ATInternetTracker/Sources/TrackerTests-Bridging-Header.h"] + $smart_sdk + $external_dependencies
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
		st.dependency 'JRSwizzle', '1.0'
		st.dependency 'KLCPopup', '1.0'
		st.dependency 'Socket.IO-Client-Swift', '~> 12.0'
	end

    s.subspec 'watchOSTracker' do |wos|
		wos.source_files           = "ATInternetTracker/Sources/*.{h,m,swift}"
		wos.exclude_files          = ["ATInternetTracker/Sources/BackgroundTask.swift","ATInternetTracker/Sources/ATReachability.swift","ATInternetTracker/Sources/Debugger.swift","ATInternetTracker/Sources/TrackerTests-Bridging-Header.h"] + $smart_sdk + $external_dependencies
		wos.frameworks             = "CoreData", "CoreFoundation", "WatchKit"
		wos.platform				  = :watchos
		wos.resources = "ATInternetTracker/Sources/DefaultConfiguration.plist","ATInternetTracker/Sources/core.manifest.json", "ATInternetTracker/Sources/*.xcdatamodeld"
	end

    s.subspec 'tvOSTracker' do |tvos|
		tvos.source_files = "ATInternetTracker/Sources/*.{h,m,swift}"
		tvos.exclude_files = $smart_sdk + $external_dependencies + ["ATInternetTracker/Sources/TrackerTests-Bridging-Header.h"]
		tvos.resources = "ATInternetTracker/Sources/*.{plist,xcdatamodeld,png,json,mp3,ttf}", "ATInternetTracker/Sources/Images.xcassets"
		tvos.frameworks = "CoreData", "CoreFoundation", "UIKit", "SystemConfiguration"
		tvos.platform = :tvos
	end
end
