# AT Internet Apple SDK

The AT Internet tag allows you to follow your users activity throughout your application’s lifecycle.
To help you, the tag makes available classes (helpers) enabling the quick implementation of tracking for different application events (screen loads, gestures, video plays…)

### Requirements
iOS 8.0+ or tvOS 9.0+ or watchOS 2.0
Swift 4.0
For Swift 3.0, please use v2.6.1

Supported devices : 
* iPhone 
* iPad 
* Apple TV 
* Apple Watch
* App Extension supported (you may need a different pod to avoid module conflicts, see below)

### How to get started
  - Install our library on your project (see below)
  - Check out the [documentation page] for an overview of the functionalities and code examples. _Note that this repository is refered as SDK 2.5+_

# What's new in 2.9+
* We reworked how RichMedia and the refresh cycle works. We improved the _sendPlay()_ method and added _resume()_.More info [here]
* Static framework support added for Cocoapods. A known bug is when you checkout the Podfile from an ObjC project you may need an empty swift file in your project in order to compile
* GDPR : _OptOut_ and _preventSyncWithICloud()_

# SmartTracker iOS (beta)
SmartTracker makes it quick and easy to track your mobile app performance. Using a single line of code, tag your app just by navigating through its content in our simple tagging interface available at [livetagging.atinternet-solutions.com]. Update and correct your tags in just minutes, and your changes will be pushed to users’ phones in real time: You’ll no longer need to resubmit to app stores and hope users update each time you edit your tagging. The feature is still experimental, if you need any help don't hesitate to submit an issue.

### Integration
Find the integration information by following [this link]

### Installation with CocoaPods

CocoaPods is a dependency manager which automates and simplifies the process of using 3rd-party libraries in your projects.

### Podfile

  - iOS application : 

```ruby
target 'MyProject' do
pod "ATInternet-Apple-SDK/Tracker",">=2.0"
use_frameworks!
end
```
  - tvOS application : 

```ruby
target 'MyProject' do
pod "ATInternet-Apple-SDK/tvOSTracker",">=2.0"
use_frameworks!
end
```
  - watchOS application : 

```ruby
target 'MyProject' do
pod "ATInternet-Apple-SDK/watchOSTracker",">=2.0"
use_frameworks!
end
```
  - SmartTracker (iOS only) : 

```ruby
target 'MyProject' do
pod "ATInternet-Apple-SDK/SmartTracker",">=2.0"
use_frameworks!
end
```

  - App Extension : 

```ruby

target 'MyProject App Extension' do
#pod "ATInternet-Apple-SDK/TrackerExtension",">=2.0" this works but if you need both iOS and AppExtension, you need an another pod to avoid module conflicts
pod "ATInternet-Apple-SDK-TrackerExtension",">=2.0"
use_frameworks!
end
```

### Installation with Carthage

Carthage is an alternative to **Cocoapods**. It’s a simple dependency manager for Mac and iOS, created by a group of developers from Github.

### Cartfile

Available soon. 

## Integration samples
### Tracker
```swift
// AppDelegate.swift
import Tracker

let tracker: Tracker = ATInternet.sharedInstance.defaultTracker
tracker.setSiteId(410501, sync: true, completionHandler: nil)
tracker.setLog("logp", sync: true, completionHandler: nil)
tracker.screens.add().sendView() // send a screen hit
```
### SmartTracker / LiveTagging
```swift
// AppDelegate.swift
import Tracker

let tracker: AutoTracker = ATInternet.sharedInstance.defaultTracker
tracker.setSiteId(410501, sync: true, completionHandler: nil)
tracker.setLog("logp", sync: true, completionHandler: nil)
tracker.token = "xxx-xxx-xxx"
tracker.enableLiveTagging = true // Allow you to pair with the LiveTagging interface
    
```
### SmartTracker / AutoTracker
```swift
// AppDelegate.swift
import Tracker

let tracker: AutoTracker = ATInternet.sharedInstance.defaultTracker
tracker.setSiteId(410501, sync: true, completionHandler: nil)
tracker.setLog("logp", sync: true, completionHandler: nil)
tracker.token = "xxx-xxx-xxx"
tracker.enableAutoTracking = true // start sending hit automatically
```

### License
MIT

   [this link]: <https://developers.atinternet-solutions.com/apple-universal-en/enabling-and-using-automatic-tracking-apple-universal-en/>
   [documentation page]: <https://developers.atinternet-solutions.com/apple-universal-en/getting-started-apple-universal-en/integration-of-the-swift-library-apple-universal-en/>
   [livetagging.atinternet-solutions.com]: <https://livetagging.atinternet-solutions.com/>
   [here]: <https://developers.atinternet-solutions.com/apple-universal-fr/contenus-de-lapplication-apple-universal-fr/rich-media-apple-universal-fr/#refresh-dynamique-2-9_3/>

