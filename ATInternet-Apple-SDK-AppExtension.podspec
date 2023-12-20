Pod::Spec.new do |s|
	s.name = "ATInternet-Apple-SDK-AppExtension"
	s.version = '2.23.10'
	s.summary = "AT Internet mobile analytics solution for Apple devices"
	s.homepage = "https://github.com/at-internet/atinternet-apple-sdk"
	s.documentation_url	= 'https://developers.atinternet-solutions.com/apple-en/getting-started-apple-en/operating-principle-apple-en/'
	s.license = "MIT"
	s.author = "AT Internet"
	s.requires_arc = true
	s.source = { :git => "https://github.com/at-internet/atinternet-apple-sdk.git", :tag => s.version}
	s.module_name = 'TrackerAppExtension'
	s.ios.deployment_target	= '10.0'
	s.pod_target_xcconfig = { 'OTHER_SWIFT_FLAGS' => '-DAT_EXTENSION' }
	s.source_files = "ATInternetTracker/Sources/*.{h,m,swift}"
	s.exclude_files = ["ATInternetTracker/Sources/BackgroundTask.swift","ATInternetTracker/Sources/Debugger.swift","ATInternetTracker/Sources/TrackerTests-Bridging-Header.h"]
	s.platform = :ios, "10.0"
	s.resources = "ATInternetTracker/Sources/DefaultConfiguration*", "ATInternetTracker/Sources/TrackerBundle.bundle"
end
