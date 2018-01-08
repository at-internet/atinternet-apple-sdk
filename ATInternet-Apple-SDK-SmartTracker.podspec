$smart_sdk = File.readlines('smartsdk.txt').map(&:strip)
$external_dependencies = File.readlines('dependencies.txt').map(&:strip)

Pod::Spec.new do |s|
	s.name = "ATInternet-Apple-SDK-SmartTracker"
	s.version = '2.8.2'
	s.summary = "AT Internet mobile analytics solution for iOS App"
	s.homepage = "https://github.com/at-internet/atinternet-apple-sdk"
	s.documentation_url	= 'http://developers.atinternet-solutions.com/apple-en/getting-started-apple-en/operating-principle-apple-en/'
	s.license = "MIT"
	s.author = "AT Internet"
	s.requires_arc = true
	s.source = { :git => "https://github.com/at-internet/atinternet-apple-sdk.git", :tag => s.version}
	s.module_name = 'SmartTracker'
  s.pod_target_xcconfig	  = { 'OTHER_SWIFT_FLAGS' => '-DAT_EXTENSION', 'SWIFT_VERSION' => '4.0' }
  s.source_files = "ATInternetTracker/Sources/*.{h,m,swift}"
  s.exclude_files = $external_dependencies + ["ATInternetTracker/Sources/TrackerTests-Bridging-Header.h"]
  s.resources = "ATInternetTracker/Sources/*.{plist,xcdatamodeld,png,json,mp3,ttf}", "ATInternetTracker/Sources/Images.xcassets", "ATInternetTracker/Sources/SmartSDK.xcassets","ATInternetTracker/Sources/en.lproj", "ATInternetTracker/Sources/fr.lproj"
  s.frameworks = "CoreData", "CoreFoundation", "UIKit", "CoreTelephony", "SystemConfiguration", "CFNetwork", "Security", "Foundation"
  s.platform				  = :ios, '8.0'
  s.pod_target_xcconfig = { 'OTHER_SWIFT_FLAGS' => '-DAT_SMART_TRACKER' }
  s.libraries = "icucore"
  s.dependency 'JRSwizzle'
  s.dependency 'KLCPopup'
  s.dependency 'Socket.IO-Client-Swift', '~> 12.0'
end