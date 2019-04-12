Pod::Spec.new do |s|
	s.name = "ATInternet-Apple-SDK"
	s.version = '2.15.0'
	s.summary = "AT Internet mobile analytics solution for Apple devices"
	s.homepage = "https://github.com/at-internet/atinternet-apple-sdk"
	s.documentation_url	= 'https://developers.atinternet-solutions.com/apple-en/getting-started-apple-en/operating-principle-apple-en/'
	s.license = "MIT"
	s.author = "AT Internet"
	s.requires_arc = true
	s.source = { :git => "https://github.com/at-internet/atinternet-apple-sdk.git", :tag => s.version}
	s.module_name = 'Tracker'
	s.ios.deployment_target	= '8.0'
	s.tvos.deployment_target = '9.0'
	s.watchos.deployment_target = '2.0'
    s.static_framework = true
    s.swift_version = '5'

	s.subspec 'Tracker' do |tracker|
		tracker.source_files = "ATInternetTracker/Sources/*.{h,m,swift}"
		tracker.resources = "ATInternetTracker/Sources/*.{plist,json}", "ATInternetTracker/Sources/TrackerBundle.bundle"
		tracker.frameworks = "CoreData", "CoreFoundation", "UIKit", "CoreTelephony", "SystemConfiguration"
		tracker.platform = :ios
	end

	s.subspec 'AppExtension' do |appExt|
		appExt.pod_target_xcconfig	  = { 'OTHER_SWIFT_FLAGS' => '-DAT_EXTENSION' }
		appExt.source_files           = "ATInternetTracker/Sources/*.{h,m,swift}"
		appExt.exclude_files          = ["ATInternetTracker/Sources/BackgroundTask.swift","ATInternetTracker/Sources/Debugger.swift","ATInternetTracker/Sources/TrackerTests-Bridging-Header.h"]
		appExt.frameworks             = "CoreData", "CoreFoundation", "WatchKit", "UIKit", "SystemConfiguration", "CoreTelephony"
		appExt.platform				  = :ios
		appExt.resources = "ATInternetTracker/Sources/*.{plist,json}", "ATInternetTracker/Sources/TrackerBundle.bundle"
	end

    s.subspec 'watchOSTracker' do |wos|
		wos.source_files           = "ATInternetTracker/Sources/*.{h,m,swift}"
		wos.exclude_files          = ["ATInternetTracker/Sources/BackgroundTask.swift","ATInternetTracker/Sources/ATReachability.swift","ATInternetTracker/Sources/Debugger.swift","ATInternetTracker/Sources/TrackerTests-Bridging-Header.h"]
		wos.frameworks             = "CoreData", "CoreFoundation", "WatchKit"
		wos.platform				  = :watchos
		wos.resources = "ATInternetTracker/Sources/DefaultConfiguration.plist","ATInternetTracker/Sources/core.manifest.json"
	end

    s.subspec 'tvOSTracker' do |tvos|
		tvos.source_files = "ATInternetTracker/Sources/*.{h,m,swift}"
		tvos.exclude_files = ["ATInternetTracker/Sources/TrackerTests-Bridging-Header.h", "ATInternetTracker/Sources/watchOSTracker.h"]
		tvos.resources = "ATInternetTracker/Sources/*.{plist,json,mp3,ttf}", "ATInternetTracker/Sources/TrackerBundle.bundle"
		tvos.frameworks = "CoreData", "CoreFoundation", "UIKit", "SystemConfiguration"
		tvos.platform = :tvos
	end
end
