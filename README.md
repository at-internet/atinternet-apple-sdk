# AT Internet Apple SDK

The AT Internet tag allows you to follow your users activity throughout your application’s lifecycle.
To help you, the tag makes available classes (helpers) enabling the quick implementation of tracking for different application events (screen loads, gestures, video plays…)

### Requirements
iOS 8.0+ or tvOS 9.0+ or watchOS 2.0
Swift 3.0

Supported devices : 
* iPhone 
* iPad 
* Apple TV 
* Apple Watch
* App Extension supported

### How to get started
  - Install our library on your project (see below)
  - Check out the [documentation page] for an overview of the functionalities and code examples. _Note that this repository is refered as SDK 2.5+_

# SmartTracker iOS (beta)
SmartTracker makes it quick and easy to track your mobile app performance. Using a single line of code, tag your app just by navigating through its content in our simple tagging interface available at [livetagging.atinternet-solutions.com]. Update and correct your tags in just minutes, and your changes will be pushed to users’ phones in real time: You’ll no longer need to resubmit to app stores and hope users update each time you edit your tagging.

### Integration
Find the integration information by following [this link]

### Installation with CocoaPods

CocoaPods is a dependency manager which automates and simplifies the process of using 3rd-party libraries in your projects.

### Podfile

  - iOS application : 

```ruby
target 'MyProject' do
pod "ATInternet-Apple-SDK/Tracker",">=1.0"
use_frameworks!
end
```
  - tvOS application : 

```ruby
target 'MyProject' do
pod "ATInternet-Apple-SDK/tvOSTracker",">=1.0"
use_frameworks!
end
```
  - watchOS application : 

```ruby
target 'MyProject' do
pod "ATInternet-Apple-SDK/watchOSTracker",">=1.0"
use_frameworks!
end
```
  - SmartTracker (iOS only) : 

```ruby
target 'MyProject' do
pod "ATInternet-Apple-SDK/SmartTracker",">=1.0"
use_frameworks!
end
```

  - App Extension : 

```ruby

target 'MyProject App Extension' do
pod "ATInternet-iOS-Swift-SDK/AppExtension",">=1.0"
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
tracker.token = "xxx-xxx-xxx"
tracker.enableLiveTagging = true // Allow you to pair with the LiveTagging interface
tracker.setSiteId(410501, sync: true, completionHandler: nil)
tracker.setLog("logp", sync: true, completionHandler: nil)
    
```
### SmartTracker / AutoTracker
```swift
// AppDelegate.swift
import Tracker

let tracker: AutoTracker = ATInternet.sharedInstance.defaultTracker
tracker.token = "xxx-xxx-xxx"
tracker.enableAutoTracking = true // start sending hit automatically
tracker.setSiteId(410501, sync: true, completionHandler: nil)
tracker.setLog("logp", sync: true, completionHandler: nil)
```

### License
MIT


   [this link]: <https://developers.atinternet-solutions.com/apple-universal-en/enabling-and-using-automatic-tracking-apple-universal-en/>
   [documentation page]: <https://developers.atinternet-solutions.com/apple-universal-en/getting-started-apple-universal-en/integration-of-the-swift-library-apple-universal-en/>
   [livetagging.atinternet-solutions.com]: <https://livetagging.atinternet-solutions.com/>

