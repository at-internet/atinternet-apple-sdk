$smart_sdk = File.readlines('smartsdk.txt').map(&:strip)
$external_dependencies = File.readlines('dependencies.txt').map(&:strip)

print $external_dependencies

Pod::Spec.new do |s|
	s.name = "ATInternet-Apple-SDK-Tracker"
	s.version = '2.8.2'
	s.summary = "AT Internet mobile analytics solution for iOS devices"
	s.homepage = "https://github.com/at-internet/atinternet-apple-sdk"
	s.documentation_url	= 'http://developers.atinternet-solutions.com/apple-en/getting-started-apple-en/operating-principle-apple-en/'
	s.license = "MIT"
	s.author = "AT Internet"
	s.requires_arc = true
	s.source = { :git => "https://github.com/at-internet/atinternet-apple-sdk.git", :tag => s.version}
	s.module_name = 'Tracker'
  s.source_files = "ATInternetTracker/Sources/*.{h,m,swift}"
  s.exclude_files = $smart_sdk + $external_dependencies
  s.resources = "ATInternetTracker/Sources/*.{plist,xcdatamodeld,png,json}", "ATInternetTracker/Sources/Images.xcassets"
  s.frameworks = "CoreData", "CoreFoundation", "UIKit", "CoreTelephony", "SystemConfiguration"
  s.platform = :ios, "8.0"
end