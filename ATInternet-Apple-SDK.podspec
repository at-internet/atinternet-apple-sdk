Pod::Spec.new do |s|
	s.name = "ATInternet-Apple-SDK"
	s.version = '2.20.0'
	s.summary = "AT Internet mobile analytics solution for Apple devices"
	s.homepage = "https://github.com/at-internet/atinternet-apple-sdk"
	s.documentation_url	= 'https://developers.atinternet-solutions.com/apple-en/getting-started-apple-en/operating-principle-apple-en/'
	s.license = "MIT"
	s.author = "AT Internet"
	s.requires_arc = true
	s.source = { :git => "https://github.com/at-internet/atinternet-apple-sdk.git", :tag => s.version}
	s.module_name = 'Tracker'
	s.ios.deployment_target	= '10.0'
	s.tvos.deployment_target = '10.0'
	s.watchos.deployment_target = '3.0'

	s.subspec 'Tracker' do |tracker|
		tracker.source_files = "ATInternetTracker/Sources/*.{h,m,swift}"
        tracker.resources = "ATInternetTracker/Sources/DefaultConfiguration*", "ATInternetTracker/Sources/TrackerBundle.bundle"
		tracker.platform = :ios
	end

	s.subspec 'AppExtension' do |appExt|
        appExt.pod_target_xcconfig = { 'OTHER_SWIFT_FLAGS' => '-DAT_EXTENSION' }
        appExt.source_files = "ATInternetTracker/Sources/*.{h,m,swift}"
        appExt.exclude_files = ["ATInternetTracker/Sources/BackgroundTask.swift","ATInternetTracker/Sources/Debugger.swift","ATInternetTracker/Sources/TrackerTests-Bridging-Header.h"]
        appExt.platform = :ios
        appExt.resources = "ATInternetTracker/Sources/DefaultConfiguration*", "ATInternetTracker/Sources/TrackerBundle.bundle"
	end

    s.subspec 'watchOSTracker' do |wos|
        wos.source_files = "ATInternetTracker/Sources/*.{h,m,swift}"
        wos.exclude_files = ["ATInternetTracker/Sources/BackgroundTask.swift","ATInternetTracker/Sources/ATReachability.swift","ATInternetTracker/Sources/Debugger.swift","ATInternetTracker/Sources/TrackerTests-Bridging-Header.h"]
        wos.platform = :watchos
        wos.resources = "ATInternetTracker/Sources/DefaultConfiguration.plist","ATInternetTracker/Sources/core.manifest.json"
    end

    s.subspec 'tvOSTracker' do |tvos|
        tvos.source_files = "ATInternetTracker/Sources/*.{h,m,swift}"
        tvos.exclude_files = ["ATInternetTracker/Sources/TrackerTests-Bridging-Header.h", "ATInternetTracker/Sources/watchOSTracker.h"]
        tvos.resources = "ATInternetTracker/Sources/DefaultConfiguration*", "ATInternetTracker/Sources/TrackerBundle.bundle"
        tvos.platform = :tvos
    end
end
