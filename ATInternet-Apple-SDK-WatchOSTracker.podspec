$smart_sdk = File.readlines('smartsdk.txt').map(&:strip)
$external_dependencies = File.readlines('dependencies.txt').map(&:strip)

Pod::Spec.new do |s|
	s.name = "ATInternet-Apple-SDK-WatchOSTracker"
	s.version = '2.8.1'
	s.summary = "AT Internet mobile analytics solution for watchos Apps"
	s.homepage = "https://github.com/at-internet/atinternet-apple-sdk"
	s.documentation_url	= 'http://developers.atinternet-solutions.com/apple-en/getting-started-apple-en/operating-principle-apple-en/'
	s.license = "MIT"
	s.author = "AT Internet"
	s.requires_arc = true
	s.source = { :git => "https://github.com/at-internet/atinternet-apple-sdk.git", :tag => s.version}
	s.module_name = 'WatchOSTracker'
  s.source_files           = "ATInternetTracker/Sources/*.{h,m,swift}"
  s.exclude_files          = ["ATInternetTracker/Sources/BackgroundTask.swift","ATInternetTracker/Sources/ATReachability.swift","ATInternetTracker/Sources/Debugger.swift","ATInternetTracker/Sources/TrackerTests-Bridging-Header.h"] + $smart_sdk + $external_dependencies
  s.frameworks             = "CoreData", "CoreFoundation", "WatchKit"
  s.platform				  = :watchos
  s.resources = "ATInternetTracker/Sources/DefaultConfiguration.plist","ATInternetTracker/Sources/core.manifest.json", "ATInternetTracker/Sources/*.xcdatamodeld"
end