# PoporWatchMemory

[![CI Status](https://img.shields.io/travis/popor/PoporWatchMemory.svg?style=flat)](https://travis-ci.org/popor/PoporWatchMemory)
[![Version](https://img.shields.io/cocoapods/v/PoporWatchMemory.svg?style=flat)](https://cocoapods.org/pods/PoporWatchMemory)
[![License](https://img.shields.io/cocoapods/l/PoporWatchMemory.svg?style=flat)](https://cocoapods.org/pods/PoporWatchMemory)
[![Platform](https://img.shields.io/cocoapods/p/PoporWatchMemory.svg?style=flat)](https://cocoapods.org/pods/PoporWatchMemory)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

PoporWatchMemory is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'PoporWatchMemory'

[PoporWatchMemory watchVcIgnoreArray:@[@"UINavigationController", @"UIEditingOverlayViewController", @"UIInputWindowController"] warn:^(NSArray<PoporWatchMemoryEntity *> * _Nonnull array, NSMutableString * description) {
    NSLog(@": %@", description); 
}];

```

<p>
<img src="/screen/1.png" width="60%" height="60%">
</p>

## Author

popor, 908891024@qq.com

## License

PoporWatchMemory is available under the MIT license. See the LICENSE file for more info.
