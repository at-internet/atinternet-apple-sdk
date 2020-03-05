# AT Internet Apple SDK

The AT Internet tag allows you to follow your users activity throughout your application’s lifecycle.
To help you, the tag makes available classes (helpers) enabling the quick implementation of tracking for different application events (screen loads, gestures, video plays…)

### Requirements
iOS 9.0+ or tvOS 9.0+ or watchOS 2.0

Supported devices : 
* iPhone 
* iPad 
* Apple TV 
* Apple Watch
* App Extension supported (you may need a different pod to avoid module conflicts, see below)

### How to get started
  - Install our library on your project (see below)
  - Check out the [documentation page] for an overview of the functionalities and code examples. _Note that this repository is refered as SDK 2.5+_

# What's new
* We reworked how RichMedia and the refresh cycle works. We improved the _sendPlay()_ method and added _resume()_.More info [here]
* Static framework support added for Cocoapods. It works well for Swift Apps but the ObjC integration seems unstable.
* GDPR : _ATInternet.OptOut_ , _ATInternet.preventICloudSync_ , _ATInternet.databasePath_

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


  - App Extension : 

```ruby

target 'MyProject App Extension' do
pod "ATInternet-Apple-SDK/AppExtension",">=2.0" 
use_frameworks!
end
```

### Installation with Carthage

Carthage is an alternative to **Cocoapods**. It’s a simple dependency manager for Mac and iOS, created by a group of developers from Github.

### Carthage

https://developers.atinternet-solutions.com/apple-universal-fr/bien-commencer-apple-universal-fr/integration-de-la-bibliotheque-swift-apple-universal-fr/#utilisation-de-carthage_7

### Installation with Swift Package Manager

This is an early preview for iOS only.

```swift
dependencies: [
  .package(url: "https://github.com/at-internet/atinternet-apple-sdk.git", from: "2.16.4"),
],
```

Until we have ressource in Swift Package Manager you should add them manually to your project.
- `ATInternetTracker/Sources/DefaultConfiguration*`
- `ATInternetTracker/Sources/TrackerBundle.bundle`

## Integration samples
### Tracker
```swift
// AppDelegate.swift
import Tracker
let trackerDelegate = DefaultTrackerDelegate() // weak var !

let tracker: Tracker = ATInternet.sharedInstance.defaultTracker
tracker.setSiteId(410501, sync: true, completionHandler: nil) // required
tracker.setLog("logp", sync: true, completionHandler: nil) // required
// tracker.enableDebugger = true // track the hit sent
// tracker.delegate = trackerDelegate // verbose mode
tracker.screens.add().sendView() // send a screen hit
```

### License
MIT

   [documentation page]: <https://developers.atinternet-solutions.com/apple-universal-en/getting-started-apple-universal-en/integration-of-the-swift-library-apple-universal-en/>
   [here]: <https://developers.atinternet-solutions.com/apple-universal-fr/contenus-de-lapplication-apple-universal-fr/rich-media-apple-universal-fr/#refresh-dynamique-2-9_3/>
