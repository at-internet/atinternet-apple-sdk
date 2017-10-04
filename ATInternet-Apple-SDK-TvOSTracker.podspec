$smart_sdk = File.readlines('smartsdk.txt').map(&:strip)
$external_dependencies = File.readlines('dependencies.txt').map(&:strip)

Pod::Spec.new do |s|
	s.name = "ATInternet-Apple-SDK-TvOSTracker"
	s.version = '2.8.0'
	s.summary = "AT Internet mobile analytics solution for iOS App Extension"
	s.homepage = "https://github.com/at-internet/atinternet-apple-sdk"
	s.documentation_url	= 'http://developers.atinternet-solutions.com/apple-en/getting-started-apple-en/operating-principle-apple-en/'
	s.license = "MIT"
	s.author = "AT Internet"
	s.requires_arc = true
	s.source = { :git => "https://github.com/at-internet/atinternet-apple-sdk.git", :tag => s.version}
	s.module_name = 'TvOSTracker'
  s.source_files = "ATInternetTracker/Sources/*.{h,m,swift}"
  s.exclude_files = $smart_sdk + $external_dependencies + ["ATInternetTracker/Sources/TrackerTests-Bridging-Header.h"]
  s.resources = "ATInternetTracker/Sources/*.{plist,xcdatamodeld,png,json,mp3,ttf}", "ATInternetTracker/Sources/Images.xcassets"
  s.frameworks = "CoreData", "CoreFoundation", "UIKit", "SystemConfiguration"
  s.platform = :tvos
end