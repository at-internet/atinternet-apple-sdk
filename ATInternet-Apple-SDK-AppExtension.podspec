$smart_sdk = File.readlines('smartsdk.txt').map(&:strip)
$external_dependencies = File.readlines('dependencies.txt').map(&:strip)

Pod::Spec.new do |s|
	s.name = "ATInternet-Apple-SDK-AppExtension"
	s.version = '2.9.7'
	s.summary = "AT Internet mobile analytics solution for iOS App Extension"
	s.homepage = "https://github.com/at-internet/atinternet-apple-sdk"
	s.documentation_url	= 'http://developers.atinternet-solutions.com/apple-en/getting-started-apple-en/operating-principle-apple-en/'
	s.license = "MIT"
	s.author = "AT Internet"
	s.requires_arc = true
	s.source = { :git => "https://github.com/at-internet/atinternet-apple-sdk.git", :tag => s.version}
	s.module_name = 'TrackerExtension'
    s.static_framework = true
  s.pod_target_xcconfig	  = { 'OTHER_SWIFT_FLAGS' => '-DAT_EXTENSION' }
  s.source_files           = "ATInternetTracker/Sources/*.{h,m,swift}"
  s.exclude_files          = ["ATInternetTracker/Sources/BackgroundTask.swift","ATInternetTracker/Sources/Debugger.swift","ATInternetTracker/Sources/TrackerTests-Bridging-Header.h"] + $smart_sdk + $external_dependencies
  s.frameworks             = "CoreData", "CoreFoundation", "WatchKit", "UIKit", "SystemConfiguration", "CoreTelephony"
  s.platform				  = :ios, '8.0'
  s.resources = "ATInternetTracker/Sources/*.{plist,json}", "ATInternetTracker/Sources/TrackerBundle.bundle"
  s.swift_version = '4.1'
end
